<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\Event;
use App\Models\Expense;
use App\Models\ExpenseSplit;
use App\Models\Notification;
use App\Models\Participant;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ExpenseController extends Controller
{
    public function create(Request $request)
    {
        $request->validate([
            'event_id' => 'required|integer|exists:events,event_id',
            'title' => 'nullable|string|max:150',
            'amount' => 'required|numeric|gt:0',
            'currency' => 'nullable|string|size:3',
            'description' => 'nullable|string|max:500',
            'expense_date' => 'nullable|date',
            'split_method' => 'nullable|in:equal,exact,percentage,share',
            'payer_id' => 'nullable|integer|exists:participants,participant_id',
        ], [
            'event_id.required' => 'Vui lòng chọn sự kiện.',
            'event_id.exists' => 'Sự kiện không tồn tại.',
            'amount.required' => 'Vui lòng nhập số tiền.',
            'amount.gt' => 'Số tiền phải lớn hơn 0.',
            'title.max' => 'Tiêu đề không được quá 150 ký tự.',
            'description.max' => 'Mô tả không được quá 500 ký tự.',
            'split_method.in' => 'Phương thức chia tiền không hợp lệ.',
        ]);

        $user = $request->user();
        $event = Event::findOrFail($request->event_id);

        // Kiem tra user co quyen them chi tieu vao su kien
        $isOwner = $event->owner_id === $user->id;
        $userParticipant = Participant::where('event_id', $event->event_id)
            ->where('user_id', $user->id)
            ->where('status', Participant::STATUS_ACTIVE)
            ->first();

        if (! $isOwner && ! $userParticipant) {
            return response()->json([
                'message' => 'Bạn không phải thành viên của sự kiện này.',
            ], 403);
        }

        // Payer: mac dinh la participant cua user, hoac theo payer_id duoc chi dinh
        if ($request->filled('payer_id')) {
            $payer = Participant::where('participant_id', $request->payer_id)
                ->where('event_id', $event->event_id)
                ->where('status', Participant::STATUS_ACTIVE)
                ->first();

            if (! $payer) {
                return response()->json([
                    'message' => 'Người trả không hợp lệ cho sự kiện này.',
                ], 422);
            }
        } else {
            if (! $userParticipant) {
                return response()->json([
                    'message' => 'Bạn chưa tham gia sự kiện này.',
                ], 403);
            }
            $payer = $userParticipant;
        }

        // Category: uu tien danh muc mac dinh loai expense
        $category = Category::where('type', Category::TYPE_EXPENSE)
            ->where('is_default', true)
            ->orderBy('category_id')
            ->first();

        if (! $category) {
            $category = Category::create([
                'name' => 'Khác',
                'icon' => 'receipt',
                'type' => Category::TYPE_EXPENSE,
                'is_default' => true,
            ]);
        }

        $splitMethod = $request->split_method ?? Expense::SPLIT_EQUAL;
        $expenseDate = $request->expense_date ?? now()->toDateString();
        $title = $request->filled('title') ? $request->title : 'Chi tiêu mới';

        $expense = DB::transaction(function () use (
            $request,
            $event,
            $user,
            $payer,
            $category,
            $splitMethod,
            $expenseDate,
            $title
        ) {
            $expense = Expense::create([
                'event_id' => $event->event_id,
                'created_by' => $user->id,
                'payer_id' => $payer->participant_id,
                'category_id' => $category->category_id,
                'title' => $title,
                'description' => $request->description,
                'amount' => $request->amount,
                'currency' => $request->currency ?? 'VND',
                'expense_date' => $expenseDate,
                'expense_type' => 'expense',
                'split_method' => $splitMethod,
                'note' => $request->description,
                'is_deleted' => false,
            ]);

            $splits = $this->buildSplits($event, (float) $request->amount, $splitMethod);

            foreach ($splits as $split) {
                ExpenseSplit::create([
                    'expense_id' => $expense->expense_id,
                    'participant_id' => $split['participant_id'],
                    'amount' => $split['amount'],
                    'status' => ExpenseSplit::STATUS_PENDING,
                ]);
            }

            // Thong bao cho cac thanh vien khac
            $this->notifyParticipants($event, $user, $expense);

            return $expense;
        });

        return response()->json([
            'message' => 'Thêm chi tiêu thành công',
            'data' => [
                'expense_id' => $expense->expense_id,
                'event_id' => $expense->event_id,
                'title' => $expense->title,
                'amount' => (float) $expense->amount,
                'currency' => $expense->currency,
                'description' => $expense->description,
                'expense_date' => $expense->expense_date,
                'split_method' => $expense->split_method,
                'category' => $category->name,
            ],
        ], 201);
    }

    /**
     * Tao danh sach chia tien theo phuong thuc.
     */
    private function buildSplits(Event $event, float $amount, string $method): array
    {
        $participants = $event->participants()
            ->where('status', Participant::STATUS_ACTIVE)
            ->orderBy('participant_id')
            ->get();

        if ($participants->isEmpty()) {
            return [];
        }

        if ($method === Expense::SPLIT_EQUAL) {
            $count = $participants->count();
            $perPerson = floor($amount * 100 / $count) / 100;
            $splits = [];

            foreach ($participants as $index => $participant) {
                $isLast = $index === $count - 1;
                $splits[] = [
                    'participant_id' => $participant->participant_id,
                    'amount' => $isLast
                        ? round($amount - $perPerson * ($count - 1), 2)
                        : $perPerson,
                ];
            }

            return $splits;
        }

        // Cac phuong thuc khac (exact/percentage/share) chua ho tro: chia deu
        $count = $participants->count();
        $perPerson = round($amount / $count, 2);

        return $participants->map(fn (Participant $p) => [
            'participant_id' => $p->participant_id,
            'amount' => $perPerson,
        ])->all();
    }

    private function notifyParticipants(Event $event, $user, Expense $expense): void
    {
        $others = $event->participants()
            ->where('status', Participant::STATUS_ACTIVE)
            ->where('user_id', '!=', $user->id)
            ->whereNotNull('user_id')
            ->get();

        foreach ($others as $participant) {
            Notification::create([
                'user_id' => $participant->user_id,
                'type' => Notification::TYPE_EXPENSE_ADDED,
                'title' => 'Chi tiêu mới trong '.$event->title,
                'content' => $user->name.' đã thêm chi tiêu "'.$expense->title.'" '.number_format((float) $expense->amount).'đ',
                'reference_id' => $expense->expense_id,
                'is_read' => false,
            ]);
        }
    }
}
