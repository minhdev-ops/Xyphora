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

    public function show(Request $request, int $event)
    {
        $user = $request->user();

        $event = Event::with(['participants.user'])->find($event);

        if (! $event) {
            return response()->json([
                'message' => 'Sự kiện không tồn tại.',
            ], 404);
        }

        $isOwner = $event->owner_id === $user->id;
        $isParticipant = $event->participants()
            ->where('user_id', $user->id)
            ->where('status', Participant::STATUS_ACTIVE)
            ->exists();

        if (! $isOwner && ! $isParticipant) {
            return response()->json([
                'message' => 'Bạn không phải thành viên của sự kiện này.',
            ], 403);
        }

        $participants = $event->participants()
            ->where('status', Participant::STATUS_ACTIVE)
            ->orderBy('participant_id')
            ->get()
            ->map(fn (Participant $p) => [
                'participant_id' => $p->participant_id,
                'user_id' => $p->user_id,
                'display_name' => $p->display_name ?: ($p->user?->name ?? $p->email),
                'email' => $p->email ?: $p->user?->email,
                'avatar' => $p->avatar ?: $p->user?->avatar,
                'is_me' => $p->user_id === $user->id,
                'role' => $p->role,
            ]);

        return response()->json([
            'message' => 'Lấy chi tiết sự kiện thành công',
            'data' => [
                'event_id' => $event->event_id,
                'title' => $event->title,
                'icon' => $event->icon,
                'currency' => $event->currency,
                'description' => $event->description,
                'status' => $event->status,
                'start_date' => $event->start_date?->toDateString(),
                'end_date' => $event->end_date?->toDateString(),
                'is_owner' => $isOwner,
                'participants' => $participants,
            ],
        ]);
    }
}