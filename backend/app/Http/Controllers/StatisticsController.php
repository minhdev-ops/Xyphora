<?php

namespace App\Http\Controllers;

use App\Models\Event;
use App\Models\Expense;
use App\Models\Participant;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StatisticsController extends Controller
{
    public function general(Request $request): JsonResponse
    {
        $user = $request->user();

        $participantIds = Participant::where('user_id', $user->id)
            ->where('status', Participant::STATUS_ACTIVE)
            ->pluck('participant_id');

        $eventIds = Event::where('owner_id', $user->id)
            ->orWhereIn('event_id', $participantIds)
            ->pluck('event_id');

        $query = Expense::where(function ($q) use ($user, $eventIds) {
                $q->whereNull('event_id')->where('created_by', $user->id);
                $q->orWhereIn('event_id', $eventIds);
            });

        $start = $request->query('start_date');
        $end = $request->query('end_date');
        if ($start && $end) {
            $query->whereBetween('expense_date', [Carbon::parse($start), Carbon::parse($end)]);
        } elseif ($start) {
            $query->whereDate('expense_date', '>=', Carbon::parse($start));
        } elseif ($end) {
            $query->whereDate('expense_date', '<=', Carbon::parse($end));
        }

        $groupBy = $request->query('group_by', 'month');
        if ($groupBy !== 'month') {
            return response()->json([
                'message' => 'Giá trị group_by không được hỗ trợ. Chỉ hỗ trợ: month',
            ], 422);
        }

        $expenses = $query->with('category')->get();

        $total = (float) $expenses->sum('amount');

        $palette = [
            0xFF4CAF50, 0xFF3B82F6, 0xFF8B5CF6, 0xFFF59E0B, 0xFFEF4444, 0xFF10B981, 0xFFEC4899,
        ];

        $byCategory = [];
        foreach ($expenses as $expense) {
            $name = $expense->category?->name ?? 'Khác';
            $byCategory[$name] = ($byCategory[$name] ?? 0) + (float) $expense->amount;
        }

        $categoryStats = [];
        $index = 0;
        foreach ($byCategory as $name => $amount) {
            $categoryStats[] = [
                'name' => $name,
                'amount' => round($amount, 2),
                'color' => $palette[$index % count($palette)],
                'percent' => $total > 0 ? round($amount / $total * 100) : 0,
            ];
            $index++;
        }

        $monthlyStats = [];
        $monthlyTransactions = [];
        for ($month = 1; $month <= 12; $month++) {
            $label = 'T'.$month;
            $monthlyStats[] = ['label' => $label, 'value' => 0.0];
            $monthlyTransactions[$label] = [];
        }

        foreach ($expenses as $expense) {
            $label = 'T'.(int) $expense->expense_date->format('n');
            $monthIndex = (int) $expense->expense_date->format('n') - 1;
            $monthlyStats[$monthIndex]['value'] += (float) $expense->amount;
            $monthlyTransactions[$label][] = [
                'name' => $expense->title,
                'categoryName' => $expense->category?->name ?? 'Khác',
                'amount' => round((float) $expense->amount, 2),
                'color' => $palette[($expense->category_id ?? 0) % count($palette)],
            ];
        }

        return response()->json([
            'data' => [
                'totalExpense' => round($total, 2),
                'changeRate' => 0.0,
                'categoryStats' => $categoryStats,
                'monthlyStats' => $monthlyStats,
                'monthlyTransactions' => $monthlyTransactions,
            ],
        ]);
    }
}
