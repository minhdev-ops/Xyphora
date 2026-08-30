<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\Event;
use App\Models\Expense;
use App\Models\ExpenseHistory;
use App\Models\ExpensePayer;
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
            'category_id' => 'nullable|integer|exists:categories,category_id',
            'title' => 'nullable|string|max:150',
            'amount' => 'required|numeric|gt:0',
            'currency' => 'nullable|string|size:3',
            'description' => 'nullable|string|max:500',
            'expense_date' => 'nullable|date',
            'split_method' => 'nullable|in:equal,percent,amount,exact,percentage,share',
            'payer_id' => 'nullable|integer|exists:participants,participant_id',
            'payer_ids' => 'nullable|array',
            'payer_ids.*' => 'integer|exists:participants,participant_id',
            'splits' => 'nullable|array',
        ], [
            'event_id.exists' => 'Sự kiện không tồn tại.',
            'category_id.exists' => 'Danh mục không tồn tại.',
            'amount.required' => 'Vui lòng nhập số tiền.',
            'amount.gt' => 'Số tiền phải lớn hơn 0.',
            'title.max' => 'Tiêu đề không được quá 150 ký tự.',
            'description.max' => 'Mô tả không được quá 500 ký tự.',
            'split_method.in' => 'Phương thức chia tiền không hợp lệ.',
        ]);

        $user = $request->user();

        // Chi tieu ca nhan (khong thuoc su kien nao)
        $event = null;
        $payerIds = [];
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

            // Nguoi tra: uu tien payer_ids (nhieu nguoi), roi payer_id, mac dinh la participant cua user
            if ($request->filled('payer_ids')) {
                $payerIds = Participant::whereIn('participant_id', $request->payer_ids)
                    ->where('event_id', $event->event_id)
                    ->where('status', Participant::STATUS_ACTIVE)
                    ->pluck('participant_id')
                    ->all();

                if (empty($payerIds)) {
                    return response()->json([
                        'message' => 'Người trả không hợp lệ cho sự kiện này.',
                    ], 422);
                }
            } elseif ($request->filled('payer_id')) {
                $payer = Participant::where('participant_id', $request->payer_id)
                    ->where('event_id', $event->event_id)
                    ->where('status', Participant::STATUS_ACTIVE)
                    ->first();

                if (! $payer) {
                    return response()->json([
                        'message' => 'Người trả không hợp lệ cho sự kiện này.',
                    ], 422);
                }

                $payerIds = [$payer->participant_id];
            } else {
                if (! $userParticipant) {
                    return response()->json([
                        'message' => 'Bạn chưa tham gia sự kiện này.',
                    ], 403);
                }

                $payerIds = [$userParticipant->participant_id];
            }
        }

        // Category: uu tien danh muc duoc chon, mac dinh la danh muc mac dinh loai expense
        $category = null;
        if ($request->filled('category_id')) {
            $category = Category::where('category_id', $request->category_id)
                ->where('type', Category::TYPE_EXPENSE)
                ->where(function ($q) use ($user) {
                    $q->where('is_default', true)
                        ->orWhere('created_by', $user->id);
                })
                ->first();

            if (! $category) {
                return response()->json([
                    'message' => 'Danh mục không hợp lệ.',
                ], 422);
            }
        }

        if (! $category) {
            $category = Category::where('type', Category::TYPE_EXPENSE)
                ->where('is_default', true)
                ->orderBy('category_id')
                ->first();
        }

        if (! $category) {
            $category = Category::create([
                'name' => 'Khác',
                'icon' => 'receipt',
                'type' => Category::TYPE_EXPENSE,
                'is_default' => true,
            ]);
        }

        $rawMethod = $request->input('split_method', 'equal');
        $splitMethod = match ($rawMethod) {
            'percent', 'percentage' => Expense::SPLIT_PERCENTAGE,
            'amount', 'exact' => Expense::SPLIT_EXACT,
            'share' => Expense::SPLIT_SHARE,
            default => Expense::SPLIT_EQUAL,
        };
        $expenseDate = $request->expense_date ?? now()->toDateString();
        $title = mb_substr(
            $request->filled('title') ? $request->title : 'Chi tiêu mới',
            0,
            150
        );

        $expense = DB::transaction(function () use (
            $request,
            $event,
            $user,
            $payerIds,
            $category,
            $splitMethod,
            $expenseDate,
            $title
        ) {
            $payer = $payerIds !== [] ? Participant::find($payerIds[0]) : null;

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

            $historyFields = [
                'title' => ['old' => null, 'new' => $title],
                'amount' => ['old' => null, 'new' => $request->amount],
                'category_id' => ['old' => null, 'new' => $category->category_id],
                'expense_date' => ['old' => null, 'new' => $expenseDate],
                'split_method' => ['old' => null, 'new' => $splitMethod],
            ];
            foreach ($historyFields as $field => $values) {
                ExpenseHistory::create([
                    'expense_id' => $expense->expense_id,
                    'updated_by' => $user->id,
                    'field_name' => $field,
                    'old_value' => $values['old'],
                    'new_value' => (string) $values['new'],
                ]);
            }

            // Chi tieu thuoc su kien moi chia tien, ghi nguoi tra va thong bao
            if ($event !== null && $payerIds !== []) {
                $totalAmount = (float) $request->amount;

                // Ghi nguoi tra (nhieu nguoi thi chia deu so tien phai tra)
                $perPayer = round($totalAmount / count($payerIds), 2);
                $remaining = $totalAmount;
                foreach ($payerIds as $index => $participantId) {
                    $isLast = $index === count($payerIds) - 1;
                    $payerAmount = $isLast ? round($remaining, 2) : $perPayer;

                    ExpensePayer::create([
                        'expense_id' => $expense->expense_id,
                        'participant_id' => $participantId,
                        'amount' => $payerAmount,
                    ]);

                    $remaining -= $perPayer;
                }

                // Chia tien theo phuong thuc da chon
                $splits = $this->buildSplits(
                    $event,
                    $totalAmount,
                    $splitMethod,
                    $request->input('splits', [])
                );

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
                'payers' => $expense->payers()
                    ->with('participant')
                    ->get()
                    ->map(fn (ExpensePayer $p) => [
                        'participant_id' => $p->participant_id,
                        'user_id' => $p->participant?->user_id,
                        'display_name' => $p->participant?->display_name,
                        'amount' => (float) $p->amount,
                    ]),
            ],
        ], 201);
    }

    public function update(Request $request, int $expense)
    {
        $expense = Expense::findOrFail($expense);

        if ($expense->is_deleted) {
            return response()->json([
                'message' => 'Chi tiêu này đã bị xóa.',
            ], 404);
        }

        $user = $request->user();

        if ($expense->event_id !== null) {
            $event = Event::findOrFail($expense->event_id);
            $isOwner = $event->owner_id === $user->id;
            $userParticipant = Participant::where('event_id', $event->event_id)
                ->where('user_id', $user->id)
                ->where('status', Participant::STATUS_ACTIVE)
                ->first();

            if (! $isOwner && ! $userParticipant) {
                return response()->json([
                    'message' => 'Bạn không có quyền sửa chi tiêu này.',
                ], 403);
            }
        } else {
            if ($expense->created_by !== $user->id) {
                return response()->json([
                    'message' => 'Bạn không có quyền sửa chi tiêu này.',
                ], 403);
            }
        }

        $request->validate([
            'category_id' => 'nullable|integer|exists:categories,category_id',
            'title' => 'nullable|string|max:150',
            'amount' => 'required|numeric|gt:0',
            'currency' => 'nullable|string|size:3',
            'description' => 'nullable|string|max:500',
            'expense_date' => 'nullable|date',
            'split_method' => 'nullable|in:equal,percent,amount,exact,percentage,share',
            'payer_id' => 'nullable|integer|exists:participants,participant_id',
            'payer_ids' => 'nullable|array',
            'payer_ids.*' => 'integer|exists:participants,participant_id',
            'splits' => 'nullable|array',
        ], [
            'category_id.exists' => 'Danh mục không tồn tại.',
            'amount.required' => 'Vui lòng nhập số tiền.',
            'amount.gt' => 'Số tiền phải lớn hơn 0.',
            'title.max' => 'Tiêu đề không được quá 150 ký tự.',
            'description.max' => 'Mô tả không được quá 500 ký tự.',
            'currency.size' => 'Tiền tệ phải gồm 3 ký tự.',
            'expense_date.date' => 'Ngày chi tiêu không hợp lệ.',
        ]);

        $category = null;
        if ($request->filled('category_id')) {
            $category = Category::where('category_id', $request->category_id)
                ->where('type', Category::TYPE_EXPENSE)
                ->where(function ($q) use ($user) {
                    $q->where('is_default', true)
                        ->orWhere('created_by', $user->id);
                })
                ->first();

            if (! $category) {
                return response()->json([
                    'message' => 'Danh mục không hợp lệ.',
                ], 422);
            }
        }

        if (! $category) {
            $category = Category::where('category_id', $expense->category_id)->first();
        }

        $rawMethod = $request->input('split_method', $expense->split_method);
        $splitMethod = match ($rawMethod) {
            'percent', 'percentage' => Expense::SPLIT_PERCENTAGE,
            'amount', 'exact' => Expense::SPLIT_EXACT,
            'share' => Expense::SPLIT_SHARE,
            default => Expense::SPLIT_EQUAL,
        };
        $expenseDate = $request->expense_date ?? $expense->expense_date;
        $title = mb_substr(
            $request->filled('title') ? $request->title : $expense->title,
            0,
            150
        );

        DB::transaction(function () use (
            $request,
            $expense,
            $user,
            $category,
            $splitMethod,
            $expenseDate,
            $title
        ) {
            $oldValues = [
                'title' => $expense->title,
                'amount' => $expense->amount,
                'category_id' => $expense->category_id,
                'expense_date' => $expense->expense_date,
                'split_method' => $expense->split_method,
                'description' => $expense->description,
            ];

            $expense->update([
                'category_id' => $category->category_id,
                'title' => $title,
                'description' => $request->description,
                'amount' => $request->amount,
                'currency' => $request->currency ?? $expense->currency,
                'expense_date' => $expenseDate,
                'split_method' => $splitMethod,
                'note' => $request->description,
            ]);

            $newValues = [
                'title' => $title,
                'amount' => $request->amount,
                'category_id' => $category->category_id,
                'expense_date' => $expenseDate,
                'split_method' => $splitMethod,
                'description' => $request->description,
            ];
            foreach ($oldValues as $field => $oldVal) {
                $newVal = $newValues[$field];
                if ((string) ($oldVal ?? '') !== (string) ($newVal ?? '')) {
                    ExpenseHistory::create([
                        'expense_id' => $expense->expense_id,
                        'updated_by' => $user->id,
                        'field_name' => $field,
                        'old_value' => $oldVal !== null ? (string) $oldVal : null,
                        'new_value' => $newVal !== null ? (string) $newVal : null,
                    ]);
                }
            }

            if ($expense->event_id !== null) {
                $event = Event::findOrFail($expense->event_id);

                ExpensePayer::where('expense_id', $expense->expense_id)->delete();
                ExpenseSplit::where('expense_id', $expense->expense_id)->delete();

                $payerIds = [];
                if ($request->filled('payer_ids')) {
                    $payerIds = Participant::whereIn('participant_id', $request->payer_ids)
                        ->where('event_id', $event->event_id)
                        ->where('status', Participant::STATUS_ACTIVE)
                        ->pluck('participant_id')
                        ->all();
                } elseif ($request->filled('payer_id')) {
                    $payer = Participant::where('participant_id', $request->payer_id)
                        ->where('event_id', $event->event_id)
                        ->where('status', Participant::STATUS_ACTIVE)
                        ->first();
                    if ($payer) {
                        $payerIds = [$payer->participant_id];
                    }
                }

                if (! empty($payerIds)) {
                    $totalAmount = (float) $request->amount;
                    $perPayer = round($totalAmount / count($payerIds), 2);
                    $remaining = $totalAmount;
                    foreach ($payerIds as $index => $participantId) {
                        $isLast = $index === count($payerIds) - 1;
                        $payerAmount = $isLast ? round($remaining, 2) : $perPayer;

                        ExpensePayer::create([
                            'expense_id' => $expense->expense_id,
                            'participant_id' => $participantId,
                            'amount' => $payerAmount,
                        ]);

                        $remaining -= $perPayer;
                    }

                    $expense->update(['payer_id' => $payerIds[0]]);

                    $splits = $this->buildSplits(
                        $event,
                        $totalAmount,
                        $splitMethod,
                        $request->input('splits', [])
                    );

                    foreach ($splits as $split) {
                        ExpenseSplit::create([
                            'expense_id' => $expense->expense_id,
                            'participant_id' => $split['participant_id'],
                            'amount' => $split['amount'],
                            'status' => ExpenseSplit::STATUS_PENDING,
                        ]);
                    }
                }

                $this->notifyUpdateParticipants($event, $user, $expense);
            }
        });

        $expense->refresh();

        return response()->json([
            'message' => 'Cập nhật chi tiêu thành công',
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
                'payers' => $expense->payers()
                    ->with('participant')
                    ->get()
                    ->map(fn (ExpensePayer $p) => [
                        'participant_id' => $p->participant_id,
                        'user_id' => $p->participant?->user_id,
                        'display_name' => $p->participant?->display_name,
                        'amount' => (float) $p->amount,
                    ]),
            ],
        ]);
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

        $query = Expense::with(['event', 'category', 'payer', 'splits', 'payers.participant'])
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

        // Chi tieu ca nhan (khong thuoc su kien): phan cua toi = toan bo so tien
        $myTotalAmount += (clone $query)
            ->whereNull('event_id')
            ->where('created_by', $user->id)
            ->sum('amount');

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
                'payers' => $expense->payers
                    ->map(fn (ExpensePayer $p) => [
                        'participant_id' => $p->participant_id,
                        'user_id' => $p->participant?->user_id,
                        'display_name' => $p->participant?->display_name,
                        'avatar' => $p->participant?->avatar,
                        'amount' => (float) $p->amount,
                    ])
                    ->values(),
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
                'member_since' => $user->created_at?->format('Y-m'),
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

        $expense = Expense::with(['event', 'category', 'payer', 'splits.participant', 'payers.participant'])
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
                'payers' => $expense->payers
                    ->sortBy('participant_id')
                    ->values()
                    ->map(fn (ExpensePayer $p) => [
                        'participant_id' => $p->participant_id,
                        'user_id' => $p->participant?->user_id,
                        'display_name' => $p->participant?->display_name,
                        'avatar' => $p->participant?->avatar,
                        'amount' => (float) $p->amount,
                    ]),
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
            ->get(['category_id', 'name', 'icon', 'color', 'type', 'is_default']);

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

        // Thong ke so khoan va tong tien theo danh muc (chi tieu trong event + ca nhan)
        $expenseStats = Expense::whereIn(
            'category_id',
            $categories->pluck('category_id')
        )
            ->where(function ($q) use ($user, $accessibleEventIds) {
                $q->whereIn('event_id', $accessibleEventIds)
                    ->orWhere(function ($sub) use ($user) {
                        $sub->whereNull('event_id')->where('created_by', $user->id);
                    });
            })
            ->selectRaw('category_id, COUNT(*) as cnt, COALESCE(SUM(amount), 0) as total')
            ->groupBy('category_id')
            ->get()
            ->keyBy('category_id');

        $data = $categories->map(function (Category $category) use ($expenseStats) {
            $stats = $expenseStats->get($category->category_id);

            return [
                'category_id' => $category->category_id,
                'name' => $category->name,
                'icon' => $category->icon,
                'color' => $category->color,
                'type' => $category->type,
                'is_default' => (bool) $category->is_default,
                'expense_count' => (int) ($stats?->cnt ?? 0),
                'total_amount' => round((float) ($stats?->total ?? 0), 2),
            ];
        });

        return response()->json([
            'message' => 'Lấy danh sách danh mục thành công',
            'data' => $data,
        ]);
    }

    public function storeCategory(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:50',
            'icon' => 'nullable|string|max:30',
            'color' => 'nullable|string|max:9',
            'type' => 'nullable|in:expense,income',
        ], [
            'name.required' => 'Vui lòng nhập tên danh mục.',
            'name.max' => 'Tên danh mục không được quá 50 ký tự.',
            'icon.max' => 'Icon không hợp lệ.',
            'color.max' => 'Màu sắc không hợp lệ.',
        ]);

        $user = $request->user();

        if ($this->categoryNameExists($user->id, $request->name)) {
            return response()->json([
                'message' => 'Danh mục này đã tồn tại.',
            ], 422);
        }

        $category = Category::create([
            'name' => trim($request->name),
            'icon' => $request->icon,
            'color' => $request->color,
            'type' => $request->type ?? Category::TYPE_EXPENSE,
            'is_default' => false,
            'created_by' => $user->id,
        ]);

        return response()->json([
            'message' => 'Tạo danh mục thành công',
            'data' => [
                'category_id' => $category->category_id,
                'name' => $category->name,
                'icon' => $category->icon,
                'color' => $category->color,
                'type' => $category->type,
                'is_default' => (bool) $category->is_default,
            ],
        ], 201);
    }

    public function updateCategory(Request $request, int $category)
    {
        $request->validate([
            'name' => 'required|string|max:50',
            'icon' => 'nullable|string|max:30',
            'color' => 'nullable|string|max:9',
        ], [
            'name.required' => 'Vui lòng nhập tên danh mục.',
            'name.max' => 'Tên danh mục không được quá 50 ký tự.',
        ]);

        $user = $request->user();

        $category = Category::find($category);
        if (! $category) {
            return response()->json([
                'message' => 'Danh mục không tồn tại.',
            ], 404);
        }

        // Chỉ người tạo danh mục hoặc danh mục mặc định (dùng chung) mới được sửa
        if (! $category->is_default && (int) $category->created_by !== $user->id) {
            return response()->json([
                'message' => 'Bạn không có quyền chỉnh sửa danh mục này.',
            ], 403);
        }

        if (strtolower($category->name) !== strtolower(trim($request->name))
            && $this->categoryNameExists($user->id, $request->name)) {
            return response()->json([
                'message' => 'Danh mục này đã tồn tại.',
            ], 422);
        }

        $category->update([
            'name' => trim($request->name),
            'icon' => $request->icon,
            'color' => $request->color,
        ]);

        return response()->json([
            'message' => 'Cập nhật danh mục thành công',
            'data' => [
                'category_id' => $category->category_id,
                'name' => $category->name,
                'icon' => $category->icon,
                'color' => $category->color,
                'type' => $category->type,
                'is_default' => (bool) $category->is_default,
            ],
        ]);
    }

    public function deleteCategory(Request $request, int $category)
    {
        $user = $request->user();

        $category = Category::find($category);
        if (! $category) {
            return response()->json([
                'message' => 'Danh mục không tồn tại.',
            ], 404);
        }

        // Không thể xóa danh mục mặc định (dùng chung)
        if ($category->is_default) {
            return response()->json([
                'message' => 'Không thể xóa danh mục mặc định.',
            ], 422);
        }

        // Chỉ người tạo mới được xóa
        if ((int) $category->created_by !== $user->id) {
            return response()->json([
                'message' => 'Bạn không có quyền xóa danh mục này.',
            ], 403);
        }

        $count = Expense::where('category_id', $category->category_id)
            ->where('is_deleted', false)
            ->count();

        if ($count > 0) {
            return response()->json([
                'message' => "Danh mục đang có {$count} khoản chi, không thể xóa.",
            ], 422);
        }

        $category->delete();

        return response()->json([
            'message' => 'Xóa danh mục thành công',
        ]);
    }

    private function categoryNameExists(int $userId, string $name): bool
    {
        return Category::where('type', Category::TYPE_EXPENSE)
            ->where('name', trim($name))
            ->where(function ($q) use ($userId) {
                $q->where('is_default', true)
                    ->orWhere('created_by', $userId);
            })
            ->exists();
    }

    /**
     * Tao danh sach chia tien theo phuong thuc.
     */
    private function buildSplits(Event $event, float $amount, string $method, array $splitData = []): array
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

        // Chia theo phan tram / chinh xac: dung du lieu tu client (splits)
        if (($method === Expense::SPLIT_PERCENTAGE || $method === Expense::SPLIT_EXACT)
            && $splitData !== []) {
            $splits = [];
            $sum = 0.0;

            foreach ($splitData as $split) {
                $participantId = (int) ($split['participant_id'] ?? 0);
                $participant = $participants->firstWhere('participant_id', $participantId);

                if (! $participant) {
                    continue;
                }

                if ($method === Expense::SPLIT_PERCENTAGE) {
                    $percentage = (float) ($split['percentage'] ?? 0);
                    $splitAmount = round($amount * $percentage / 100, 2);
                } else {
                    $splitAmount = round((float) ($split['amount'] ?? 0), 2);
                }

                $sum += $splitAmount;
                $splits[] = [
                    'participant_id' => $participantId,
                    'amount' => $splitAmount,
                ];
            }

            if ($splits !== []) {
                // Dieu chinh sai so lam tron: gan hieu so vao nguoi cuoi cung
                $diff = round($amount - $sum, 2);

                if (abs($diff) > 0.01) {
                    $lastIndex = count($splits) - 1;
                    $splits[$lastIndex]['amount'] = round(
                        $splits[$lastIndex]['amount'] + $diff,
                        2
                    );
                }
            }

            return $splits;
        }

        // Cac phuong thuc khac chua ho tro: chia deu
        $count = $participants->count();
        $perPerson = round($amount / $count, 2);

        return $participants->map(fn (Participant $p) => [
            'participant_id' => $p->participant_id,
            'amount' => $perPerson,
        ])->all();
    }

    public function destroy(Request $request, int $expense)
    {
        $expense = Expense::findOrFail($expense);

        if ($expense->is_deleted) {
            return response()->json([
                'message' => 'Chi tiêu này đã bị xóa.',
            ], 404);
        }

        $user = $request->user();

        if ($expense->event_id !== null) {
            $event = Event::findOrFail($expense->event_id);
            $isOwner = $event->owner_id === $user->id;
            $userParticipant = Participant::where('event_id', $event->event_id)
                ->where('user_id', $user->id)
                ->where('status', Participant::STATUS_ACTIVE)
                ->first();

            if (! $isOwner && ! $userParticipant) {
                return response()->json([
                    'message' => 'Bạn không có quyền xóa chi tiêu này.',
                ], 403);
            }
        } else {
            if ($expense->created_by !== $user->id) {
                return response()->json([
                    'message' => 'Bạn không có quyền xóa chi tiêu này.',
                ], 403);
            }
        }

        $expense->update(['is_deleted' => true]);

        ExpenseHistory::create([
            'expense_id' => $expense->expense_id,
            'updated_by' => $user->id,
            'field_name' => 'is_deleted',
            'old_value' => '0',
            'new_value' => '1',
        ]);

        if ($expense->event_id !== null) {
            $event = Event::findOrFail($expense->event_id);
            $this->notifyDeleteParticipants($event, $user, $expense);
        }

        return response()->json([
            'message' => 'Xóa chi tiêu thành công',
        ]);
    }

    public function storeForEvent(Request $request, int $event)
    {
        $request->merge(['event_id' => $event]);

        return $this->create($request);
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

    private function notifyDeleteParticipants(Event $event, $user, Expense $expense): void
    {
        $others = $event->participants()
            ->where('status', Participant::STATUS_ACTIVE)
            ->where('user_id', '!=', $user->id)
            ->whereNotNull('user_id')
            ->get();

        foreach ($others as $participant) {
            Notification::create([
                'user_id' => $participant->user_id,
                'type' => Notification::TYPE_EXPENSE_DELETED,
                'title' => 'Chi tiêu đã xóa trong '.$event->title,
                'content' => $user->name.' đã xóa chi tiêu "'.$expense->title.'"',
                'reference_id' => $expense->expense_id,
                'is_read' => false,
            ]);
        }
    }

    private function notifyUpdateParticipants(Event $event, $user, Expense $expense): void
    {
        $others = $event->participants()
            ->where('status', Participant::STATUS_ACTIVE)
            ->where('user_id', '!=', $user->id)
            ->whereNotNull('user_id')
            ->get();

        foreach ($others as $participant) {
            Notification::create([
                'user_id' => $participant->user_id,
                'type' => Notification::TYPE_EXPENSE_UPDATED,
                'title' => 'Chi tiêu đã cập nhật trong '.$event->title,
                'content' => $user->name.' đã cập nhật chi tiêu "'.$expense->title.'" '.number_format((float) $expense->amount).'đ',
                'reference_id' => $expense->expense_id,
                'is_read' => false,
            ]);
        }
    }
}
