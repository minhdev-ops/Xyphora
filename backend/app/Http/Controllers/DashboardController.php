<?php

namespace App\Http\Controllers;

use App\Models\Event;
use App\Models\Expense;
use App\Models\ExpenseSplit;
use App\Models\Notification;
use App\Models\Participant;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function home(Request $request)
    {
        $user = $request->user();
        $userId = $user->id;

        $participantIds = Participant::where('user_id', $userId)
            ->where('status', Participant::STATUS_ACTIVE)
            ->pluck('participant_id');

        $startOfMonth = now()->startOfMonth()->toDateString();
        $endOfMonth = now()->endOfMonth()->toDateString();

        // 1. Chi tieu thang nay (phan cua user)
        $monthlySplits = ExpenseSplit::whereIn('participant_id', $participantIds)
            ->whereHas('expense', function ($q) use ($startOfMonth, $endOfMonth) {
                $q->whereBetween('expense_date', [$startOfMonth, $endOfMonth]);
            })
            ->get();

        $monthlySpending = round($monthlySplits->sum(fn ($s) => (float) $s->amount), 2);
        $monthlySpendingCount = $monthlySplits->count();

        // 2. So du: tong da tra - tong phan chia
        $paid = (float) Expense::whereIn('payer_id', $participantIds)->sum('amount');
        $owed = (float) ExpenseSplit::whereIn('participant_id', $participantIds)->sum('amount');
        $net = round($paid - $owed, 2);

        // 3. Su kien sap toi
        $myEventIds = $this->getUserEventIds($userId, $participantIds);

        $upcomingEvents = Event::whereIn('event_id', $myEventIds)
            ->where('status', 'active')
            ->where(fn ($q) => $q->whereNull('start_date')->orWhere('start_date', '>=', now()->toDateString()))
            ->orderBy('start_date')
            ->take(5)
            ->get()
            ->map(fn (Event $event) => [
                'event_id' => $event->event_id,
                'title' => $event->title,
                'icon' => $event->icon,
                'start_date' => $event->start_date?->toDateString(),
                'end_date' => $event->end_date?->toDateString(),
                'days_left' => $event->start_date
                    ? now()->startOfDay()->diffInDays($event->start_date, false)
                    : null,
                'member_count' => $event->participants()
                    ->where('status', Participant::STATUS_ACTIVE)
                    ->count(),
            ]);

        // 4. Thong bao chua doc
        $notifications = Notification::where('user_id', $userId)
            ->where('is_read', false)
            ->orderByDesc('created_at')
            ->take(5)
            ->get()
            ->map(fn (Notification $n) => [
                'notification_id' => $n->notification_id,
                'type' => $n->type,
                'title' => $n->title,
                'content' => $n->content,
                'is_read' => $n->is_read,
                'created_at' => $n->created_at,
            ])
            ->values();

        // 5. Tong hop theo tung su kien (tab "Tat ca")
        $events = Event::whereIn('event_id', $myEventIds)
            ->where('status', '!=', 'archived')
            ->orderByDesc('created_at')
            ->take(10)
            ->get();

        $transactions = $events->map(function (Event $event) use ($participantIds) {
            $eventParticipantIds = $event->participants()
                ->where('status', Participant::STATUS_ACTIVE)
                ->whereIn('participant_id', $participantIds)
                ->pluck('participant_id');

            $eventPaid = (float) Expense::where('event_id', $event->event_id)
                ->whereIn('payer_id', $eventParticipantIds)
                ->sum('amount');

            $eventOwed = (float) ExpenseSplit::whereIn('participant_id', $eventParticipantIds)
                ->whereHas('expense', fn ($q) => $q->where('event_id', $event->event_id))
                ->sum('amount');

            $net = round($eventPaid - $eventOwed, 2);

            $members = $event->participants()
                ->where('status', Participant::STATUS_ACTIVE)
                ->get();

            $initials = $members->take(4)
                ->map(fn (Participant $p) => $this->getInitials($p->display_name ?: $p->email))
                ->values()
                ->all();

            return [
                'event_id' => $event->event_id,
                'title' => $event->title,
                'date' => $event->start_date?->toDateString(),
                'member_count' => $members->count(),
                'member_initials' => $initials,
                'amount' => $net,
                'status' => $net > 0 ? 'receive' : ($net < 0 ? 'borrow' : 'done'),
            ];
        });

        // 6. Danh sach chi tieu thang nay (tab "Chi tieu cua toi")
        $monthlyExpenseIds = $monthlySplits->pluck('expense_id')->unique();

        $spendings = Expense::whereIn('expense_id', $monthlyExpenseIds)
            ->with('category')
            ->orderByDesc('expense_date')
            ->orderByDesc('created_at')
            ->get()
            ->map(function (Expense $expense) use ($monthlySplits) {
                $share = round(
                    $monthlySplits->where('expense_id', $expense->expense_id)->sum(fn ($s) => (float) $s->amount),
                    2
                );

                return [
                    'expense_id' => $expense->expense_id,
                    'event_id' => $expense->event_id,
                    'title' => $expense->title,
                    'category' => $expense->category?->name,
                    'date' => $expense->expense_date?->toDateString(),
                    'amount' => $share,
                    'note' => $expense->note,
                    'currency' => $expense->currency,
                ];
            });

        return response()->json([
            'message' => 'Lấy dữ liệu thành công',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'avatar' => $user->avatar,
                ],
                'summary' => [
                    'monthly_spending' => $monthlySpending,
                    'monthly_spending_count' => $monthlySpendingCount,
                    'balance' => [
                        'total' => $net,
                        'debt_to_you' => $net > 0 ? $net : 0,
                        'your_debt' => $net < 0 ? abs($net) : 0,
                    ],
                ],
                'upcoming_events' => $upcomingEvents,
                'notifications' => $notifications,
                'transactions' => $transactions,
                'spendings' => $spendings,
            ],
        ]);
    }

    private function getUserEventIds(int $userId, $participantIds): array
    {
        $participantEventIds = Participant::whereIn('participant_id', $participantIds)
            ->pluck('event_id');

        return Event::where('owner_id', $userId)
            ->orWhereIn('event_id', $participantEventIds)
            ->pluck('event_id')
            ->unique()
            ->values()
            ->all();
    }

    private function getInitials(string $name): string
    {
        $words = preg_split('/\s+/', trim($name));

        if (! $words) {
            return '?';
        }

        $first = mb_substr($words[0], 0, 1);
        $last = count($words) > 1 ? mb_substr($words[count($words) - 1], 0, 1) : '';

        return mb_strtoupper($first.$last);
    }
}
