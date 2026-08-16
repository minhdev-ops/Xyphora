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
            'event_id' => 'nullable|integer|exists:events,event_id',
            'title' => 'nullable|string|max:150',
            'amount' => 'required|numeric|gt:0',
            'currency' => 'nullable|string|size:3',
            'description' => 'nullable|string|max:500',
            'expense_date' => 'nullable|date',
            'split_method' => 'nullable|in:equal,exact,percentage,share',
            'payer_id' => 'nullable|integer|exists:participants,participant_id',
        ], [
            'event_id.exists' => 'Sự kiện không tồn tại.',
            'amount.required' => 'Vui lòng nhập số tiền.',
            'amount.gt' => 'Số tiền phải lớn hơn 0.',
            'title.max' => 'Tiêu đề không được quá 150 ký tự.',
            'description.max' => 'Mô tả không được quá 500 ký tự.',
            'split_method.in' => 'Phương thức chia tiền không hợp lệ.',
        ]);

        $user = $request->user();

        // Chi tieu ca nhan (khong thuoc su kien nao)
        $event = null;
        $payer = null;
        if ($request->filled('event_id')) {
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
                'event_id' => $event?->event_id,
                'created_by' => $user->id,
                'payer_id' => $payer?->participant_id,
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

            // Chi tieu thuoc su kien moi chia tien va thong bao
            if ($event !== null && $payer !== null) {
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
            }

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

    public function index(Request $request)
    {
        $request->validate([
            'event_id' => 'nullable|integer|exists:events,event_id',
            'page' => 'nullable|integer|min:1',
            'per_page' => 'nullable|integer|min:1|max:50',
            'date_from' => 'nullable|date',
            'date_to' => 'nullable|date',
            'category_id' => 'nullable|integer|exists:categories,category_id',
            'payer_id' => 'nullable|integer|exists:participants,participant_id',
            'search' => 'nullable|string|max:150',
            'my_split_status' => 'nullable|in:pending,settled',
            'sort' => 'nullable|in:asc,desc',
        ], [
            'event_id.exists' => 'Sự kiện không tồn tại.',
            'per_page.max' => 'per_page không được vượt quá 50.',
            'date_from.date' => 'date_from không hợp lệ.',
            'date_to.date' => 'date_to không hợp lệ.',
            'category_id.exists' => 'Danh mục không tồn tại.',
            'payer_id.exists' => 'Người trả không tồn tại.',
            'my_split_status.in' => 'my_split_status phải là pending hoặc settled.',
            'sort.in' => 'sort phải là asc hoặc desc.',
        ]);

        $user = $request->user();

        // Cac su kien user co quyen xem chi tieu (owner hoac participant active)
        $accessibleEventIds = Event::where('owner_id', $user->id)
            ->pluck('event_id')
            ->merge(
                Participant::where('user_id', $user->id)
                    ->where('status', Participant::STATUS_ACTIVE)
                    ->pluck('event_id')
            )
            ->unique()
            ->values();

        $eventId = $request->event_id;
        if ($eventId !== null && ! $accessibleEventIds->contains($eventId)) {
            return response()->json([
                'message' => 'Bạn không có quyền xem chi tiêu của sự kiện này.',
            ], 403);
        }

        $query = Expense::with(['event', 'category', 'payer', 'splits'])
            ->where(function ($q) use ($user, $accessibleEventIds) {
                $q->whereIn('event_id', $accessibleEventIds)
                    ->orWhere(function ($sub) use ($user) {
                        $sub->whereNull('event_id')->where('created_by', $user->id);
                    });
            });

        if ($eventId !== null) {
            $query->where('event_id', $eventId);
        }

        if ($request->filled('date_from')) {
            $query->whereDate('expense_date', '>=', $request->date_from);
        }

        if ($request->filled('date_to')) {
            $query->whereDate('expense_date', '<=', $request->date_to);
        }

        if ($request->filled('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        if ($request->filled('payer_id')) {
            $query->where('payer_id', $request->payer_id);
        }

        if ($request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('title', 'like', '%'.$request->search.'%')
                    ->orWhere('description', 'like', '%'.$request->search.'%');
            });
        }

        if ($request->filled('my_split_status')) {
            $query->whereHas('splits', function ($q) use ($request, $user) {
                $q->where('status', $request->my_split_status)
                    ->whereIn('participant_id', function ($sub) use ($user) {
                        $sub->select('participant_id')
                            ->from('participants')
                            ->where('user_id', $user->id);
                    });
            });
        }

        // Tong tien tren TOAN BO tap da loc (khong phai rieng trang)
        $summaryAmount = (clone $query)->sum('amount');

        $myParticipantIds = Participant::where('user_id', $user->id)
            ->where('status', Participant::STATUS_ACTIVE)
            ->whereIn('event_id', $accessibleEventIds)
            ->pluck('participant_id');

        $myTotalAmount = 0.0;
        if ($myParticipantIds->isNotEmpty()) {
            $myTotalAmount = (clone $query)
                ->join('expense_splits', 'expenses.expense_id', '=', 'expense_splits.expense_id')
                ->whereIn('expense_splits.participant_id', $myParticipantIds)
                ->sum('expense_splits.amount');
        }

        $sort = $request->sort ?? 'desc';
        $query->orderBy('expense_date', $sort)->orderBy('created_at', $sort);

        $perPage = $request->per_page ?? 15;
        $expenses = $query->paginate($perPage)->withQueryString();

        // Map participant cua user theo tung su kien (de tim my_split)
        $myParticipantByEvent = Participant::where('user_id', $user->id)
            ->where('status', Participant::STATUS_ACTIVE)
            ->whereIn('event_id', $accessibleEventIds)
            ->get(['event_id', 'participant_id'])
            ->keyBy('event_id');

        $data = $expenses->map(function (Expense $expense) use ($myParticipantByEvent) {
            $myParticipant = $myParticipantByEvent->get($expense->event_id);
            $mySplit = $myParticipant
                ? $expense->splits->firstWhere('participant_id', $myParticipant->participant_id)
                : null;

            return [
                'expense_id' => $expense->expense_id,
                'event_id' => $expense->event_id,
                'event_title' => $expense->event?->title,
                'title' => $expense->title,
                'description' => $expense->description,
                'amount' => (float) $expense->amount,
                'currency' => $expense->currency,
                'expense_date' => $expense->expense_date?->toDateString(),
                'split_method' => $expense->split_method,
                'category' => $expense->category ? [
                    'category_id' => $expense->category->category_id,
                    'name' => $expense->category->name,
                    'icon' => $expense->category->icon,
                    'color' => $expense->category->color,
                ] : null,
                'payer' => $expense->payer ? [
                    'participant_id' => $expense->payer->participant_id,
                    'user_id' => $expense->payer->user_id,
                    'display_name' => $expense->payer->display_name,
                    'avatar' => $expense->payer->avatar,
                ] : null,
                'my_split' => $mySplit ? [
                    'amount' => (float) $mySplit->amount,
                    'status' => $mySplit->status,
                ] : null,
                'split_count' => $expense->splits->count(),
                'created_by' => $expense->created_by,
                'created_at' => $expense->created_at?->toDateTimeString(),
            ];
        });

        return response()->json([
            'message' => 'Lấy danh sách chi tiêu thành công',
            'data' => $data,
            'summary' => [
                'total_amount' => round((float) $summaryAmount, 2),
                'my_total_amount' => round($myTotalAmount, 2),
            ],
            'meta' => [
                'current_page' => $expenses->currentPage(),
                'per_page' => $expenses->perPage(),
                'total' => $expenses->total(),
                'last_page' => $expenses->lastPage(),
                'from' => $expenses->firstItem(),
                'to' => $expenses->lastItem(),
            ],
        ]);
    }

    public function show(Request $request, int $expense)
    {
        $user = $request->user();

        $expense = Expense::with(['event', 'category', 'payer', 'splits.participant'])
            ->findOrFail($expense);

        $accessibleEventIds = Event::where('owner_id', $user->id)
            ->pluck('event_id')
            ->merge(
                Participant::where('user_id', $user->id)
                    ->where('status', Participant::STATUS_ACTIVE)
                    ->pluck('event_id')
            )
            ->unique()
            ->values();

        if ($expense->event_id === null) {
            if ($expense->created_by !== $user->id) {
                return response()->json([
                    'message' => 'Bạn không có quyền xem chi tiêu của sự kiện này.',
                ], 403);
            }
        } elseif (! $accessibleEventIds->contains($expense->event_id)) {
            return response()->json([
                'message' => 'Bạn không có quyền xem chi tiêu của sự kiện này.',
            ], 403);
        }

        $myParticipant = Participant::where('event_id', $expense->event_id)
            ->where('user_id', $user->id)
            ->where('status', Participant::STATUS_ACTIVE)
            ->first();

        $mySplit = $myParticipant
            ? $expense->splits->firstWhere('participant_id', $myParticipant->participant_id)
            : null;

        $splits = $expense->splits
            ->sortBy('participant_id')
            ->values()
            ->map(function (ExpenseSplit $split) use ($expense) {
                $participant = $split->participant;

                return [
                    'participant_id' => $split->participant_id,
                    'user_id' => $participant?->user_id,
                    'display_name' => $participant?->display_name,
                    'avatar' => $participant?->avatar,
                    'amount' => (float) $split->amount,
                    'status' => $split->status,
                    'is_payer' => $split->participant_id === $expense->payer_id,
                ];
            });

        return response()->json([
            'message' => 'Lấy chi tiết chi tiêu thành công',
            'data' => [
                'expense_id' => $expense->expense_id,
                'event_id' => $expense->event_id,
                'event_title' => $expense->event?->title,
                'title' => $expense->title,
                'description' => $expense->description,
                'amount' => (float) $expense->amount,
                'currency' => $expense->currency,
                'expense_date' => $expense->expense_date?->toDateString(),
                'split_method' => $expense->split_method,
                'created_at' => $expense->created_at?->toDateTimeString(),
                'category' => $expense->category ? [
                    'category_id' => $expense->category->category_id,
                    'name' => $expense->category->name,
                    'icon' => $expense->category->icon,
                    'color' => $expense->category->color,
                ] : null,
                'payer' => $expense->payer ? [
                    'participant_id' => $expense->payer->participant_id,
                    'user_id' => $expense->payer->user_id,
                    'display_name' => $expense->payer->display_name,
                    'avatar' => $expense->payer->avatar,
                ] : null,
                'my_split' => $mySplit ? [
                    'participant_id' => $mySplit->participant_id,
                    'amount' => (float) $mySplit->amount,
                    'status' => $mySplit->status,
                ] : null,
                'splits' => $splits,
                'split_count' => $expense->splits->count(),
            ],
        ]);
    }

    public function categories(Request $request)
    {
        $user = $request->user();

        $categories = Category::where('type', Category::TYPE_EXPENSE)
            ->where(function ($q) use ($user) {
                $q->where('is_default', true)
                    ->orWhere('created_by', $user->id);
            })
            ->orderBy('category_id')
            ->get(['category_id', 'name', 'icon', 'color', 'type']);

        return response()->json([
            'message' => 'Lấy danh sách danh mục thành công',
            'data' => $categories,
        ]);
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
