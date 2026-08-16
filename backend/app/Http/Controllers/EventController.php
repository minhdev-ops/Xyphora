<?php

namespace App\Http\Controllers;

use App\Models\Event;
use App\Models\Participant;
use Illuminate\Http\Request;

class EventController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $userId = $user->id;

        $participantEventIds = Participant::where('user_id', $userId)
            ->where('status', Participant::STATUS_ACTIVE)
            ->pluck('event_id');

        $events = Event::where(function ($q) use ($userId, $participantEventIds) {
            $q->where('owner_id', $userId)
                ->orWhereIn('event_id', $participantEventIds);
        })
            ->where('status', '!=', 'archived')
            ->orderByDesc('created_at')
            ->get()
            ->map(function (Event $event) {
                return [
                    'event_id' => $event->event_id,
                    'title' => $event->title,
                    'icon' => $event->icon,
                    'currency' => $event->currency,
                    'start_date' => $event->start_date?->toDateString(),
                    'end_date' => $event->end_date?->toDateString(),
                    'status' => $event->status,
                    'member_count' => $event->participants()
                        ->where('status', Participant::STATUS_ACTIVE)
                        ->count(),
                ];
            });

        return response()->json([
            'message' => 'Lấy danh sách sự kiện thành công',
            'data' => $events,
        ]);
    }
}
