<?php

namespace App\Http\Controllers;

use App\Models\Event;
use App\Models\Invitation;
use App\Models\Notification;
use App\Models\Participant;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class EventController extends Controller
{
    private const INVITE_LINK_PREFIX = 'xyphora://join?token=';

    private const INVITE_TTL_DAYS = 7;

    /**
     * GET /api/events - List events the authenticated user has joined.
     */
    public function index()
    {
        $userId = auth()->id();

        $events = Event::where('owner_id', $userId)
            ->orWhereHas('participants', function ($query) use ($userId) {
                $query->where('user_id', $userId)->where('status', 'active');
            })
            ->with('owner:id,name,email,avatar')
            ->withCount(['participants' => function ($query) {
                $query->where('status', 'active');
            }])
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'message' => 'Lấy danh sách sự kiện thành công',
            'data' => $events,
        ], 200);
    }

    /**
     * POST /api/events - Create a new event (as owner).
     */
    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string|max:150',
            'description' => 'nullable|string',
            'icon' => 'nullable|string|max:50',
            'cover_photo' => 'nullable|string|max:500',
            'currency' => 'nullable|string|size:3',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'status' => 'nullable|in:active,completed,archived',
            'participants' => 'nullable|array|max:100',
            'participants.*.display_name' => 'required|string|max:100',
        ], [
            'title.required' => 'Vui lòng nhập tên sự kiện.',
            'title.max' => 'Tên sự kiện không được vượt quá 150 ký tự.',
            'currency.size' => 'Mã tiền tệ phải có 3 ký tự.',
            'start_date.date' => 'Ngày bắt đầu không hợp lệ.',
            'end_date.date' => 'Ngày kết thúc không hợp lệ.',
            'end_date.after_or_equal' => 'Ngày kết thúc phải sau hoặc bằng ngày bắt đầu.',
            'status.in' => 'Trạng thái sự kiện không hợp lệ.',
            'participants.max' => 'Danh sách người tham gia không được vượt quá 100 người.',
            'participants.*.display_name.required' => 'Vui lòng nhập tên người tham gia.',
            'participants.*.display_name.max' => 'Tên người tham gia không được vượt quá 100 ký tự.',
        ]);

        $user = $request->user();

        $event = DB::transaction(function () use ($data, $user) {
            $event = Event::create(array_merge($data, [
                'owner_id' => $user->id,
                'status' => $data['status'] ?? 'active',
                'currency' => $data['currency'] ?? 'VND',
            ]));

            Participant::create([
                'event_id' => $event->event_id,
                'user_id' => $user->id,
                'display_name' => $user->name,
                'email' => $user->email,
                'avatar' => $user->avatar,
                'role' => 'owner',
                'status' => 'active',
            ]);

            foreach ($data['participants'] ?? [] as $index => $participant) {
                Participant::create([
                    'event_id' => $event->event_id,
                    'user_id' => null,
                    'display_name' => $participant['display_name'],
                    'email' => 'guest-'.$event->event_id.'-'.($index + 1).'@xyphora.local',
                    'role' => 'member',
                    'status' => 'active',
                ]);
            }

            Invitation::create([
                'event_id' => $event->event_id,
                'token' => Str::random(32),
                'expired_at' => now()->addDays(self::INVITE_TTL_DAYS),
                'status' => 'pending',
            ]);

            return $event;
        });

        $event->load('owner:id,name,email,avatar', 'participants');

        $invitation = Invitation::where('event_id', $event->event_id)
            ->orderByDesc('invitation_id')
            ->first();

        return response()->json([
            'message' => 'Tạo sự kiện thành công',
            'data' => $event,
            'invite_token' => $invitation->token,
            'invite_link' => self::INVITE_LINK_PREFIX.$invitation->token,
        ], 201);
    }

    /**
     * GET /api/events/{id} - Show event details (owner or active participant only).
     */
    public function show(Event $event)
    {
        $userId = auth()->id();

        if ($event->owner_id !== $userId
            && ! $event->participants()
                ->where('user_id', $userId)
                ->where('status', 'active')
                ->exists()) {
            return response()->json([
                'message' => 'Bạn không có quyền xem sự kiện này.',
            ], 403);
        }

        $event->load([
            'owner:id,name,email,avatar',
            'participants' => function ($query) {
                $query->where('status', 'active');
            },
            'expenses' => function ($query) {
                $query->with(['splits', 'category'])
                    ->where('is_deleted', false)
                    ->orderBy('expense_date', 'desc');
            },
        ]);

        return response()->json([
            'message' => 'Lấy thông tin sự kiện thành công',
            'data' => $event,
        ], 200);
    }

    /**
     * PUT /api/events/{id} - Update event info (owner only).
     */
    public function update(Request $request, Event $event)
    {
        if ($event->owner_id !== auth()->id()) {
            return response()->json([
                'message' => 'Chỉ người tổ chức mới được chỉnh sửa sự kiện.',
            ], 403);
        }

        $data = $request->validate([
            'title' => 'sometimes|required|string|max:150',
            'description' => 'nullable|string',
            'icon' => 'nullable|string|max:50',
            'cover_photo' => 'nullable|string|max:500',
            'currency' => 'nullable|string|size:3',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'status' => 'nullable|in:active,completed,archived',
            'participants' => 'nullable|array|max:100',
            'participants.*.participant_id' => 'nullable|integer',
            'participants.*.display_name' => 'required|string|max:100',
        ], [
            'title.required' => 'Vui lòng nhập tên sự kiện.',
            'title.max' => 'Tên sự kiện không được vượt quá 150 ký tự.',
            'currency.size' => 'Mã tiền tệ phải có 3 ký tự.',
            'start_date.date' => 'Ngày bắt đầu không hợp lệ.',
            'end_date.date' => 'Ngày kết thúc không hợp lệ.',
            'end_date.after_or_equal' => 'Ngày kết thúc phải sau hoặc bằng ngày bắt đầu.',
            'status.in' => 'Trạng thái sự kiện không hợp lệ.',
            'participants.max' => 'Danh sách người tham gia không được vượt quá 100 người.',
            'participants.*.display_name.required' => 'Vui lòng nhập tên người tham gia.',
            'participants.*.display_name.max' => 'Tên người tham gia không được vượt quá 100 ký tự.',
        ]);

        $updated = DB::transaction(function () use ($event, $data) {
            $participants = $data['participants'] ?? null;
            unset($data['participants']);

            $event->update($data);

            if ($participants !== null) {
                $this->syncParticipants($event, $participants);
            }

            return $event;
        });

        $updated->load([
            'owner:id,name,email,avatar',
            'participants' => function ($query) {
                $query->where('status', 'active');
            },
        ]);

        $updated->loadCount(['participants as participants_count' => function ($query) {
            $query->where('status', 'active');
        }]);

        return response()->json([
            'message' => 'Cập nhật sự kiện thành công',
            'data' => $updated,
        ], 200);
    }

    /**
     * Sync the event participant list based on the submitted participants.
     *
     * - The owner participant is always kept.
     * - Submitted items with a valid participant_id are kept (and reactivated if needed).
     * - Submitted items without a participant_id are added as guests
     *   (or reactivated from a matching removed participant).
     * - Existing active non-owner participants not in the submitted list are marked 'removed'.
     */
    private function syncParticipants(Event $event, array $participants): void
    {
        $existing = $event->participants()->get()->keyBy('participant_id');

        $keepIds = [];
        $nextGuestIndex = $this->nextGuestIndex($event->event_id, $existing);

        foreach ($participants as $participant) {
            $participantId = $participant['participant_id'] ?? null;
            $displayName = trim($participant['display_name'] ?? '');

            if ($participantId !== null) {
                if (! $existing->has($participantId)) {
                    continue;
                }

                $model = $existing[$participantId];

                if ($model->role === 'owner') {
                    $model->update([
                        'display_name' => $displayName !== '' ? $displayName : $model->display_name,
                    ]);
                } else {
                    $model->update([
                        'display_name' => $displayName,
                        'status' => 'active',
                    ]);
                }

                $keepIds[] = $participantId;

                continue;
            }

            $removed = $existing->first(function ($model) use ($displayName) {
                return $model->role !== 'owner'
                    && $model->status === 'removed'
                    && strcasecmp($model->display_name, $displayName) === 0;
            });

            if ($removed) {
                $removed->update([
                    'display_name' => $displayName,
                    'status' => 'active',
                ]);
                $keepIds[] = $removed->participant_id;

                continue;
            }

            $email = 'guest-'.$event->event_id.'-'.(++$nextGuestIndex).'@xyphora.local';

            $created = Participant::create([
                'event_id' => $event->event_id,
                'user_id' => null,
                'display_name' => $displayName,
                'email' => $email,
                'role' => 'member',
                'status' => 'active',
            ]);

            $keepIds[] = $created->participant_id;
        }

        $event->participants()
            ->where('role', '!=', 'owner')
            ->where('status', 'active')
            ->whereNotIn('participant_id', array_unique($keepIds))
            ->update(['status' => 'removed']);
    }

    private function nextGuestIndex(int $eventId, $existing): int
    {
        $max = 0;

        foreach ($existing as $model) {
            if (preg_match('/^guest-'.$eventId.'-(\d+)@xyphora\.local$/', $model->email, $m)) {
                $max = max($max, (int) $m[1]);
            }
        }

        return $max;
    }

    /**
     * DELETE /api/events/{id} - Delete event and notify participants (owner only).
     */
    public function destroy(Event $event)
    {
        $userId = auth()->id();

        if ($event->owner_id !== $userId) {
            return response()->json([
                'message' => 'Chỉ người tổ chức mới được xóa sự kiện.',
            ], 403);
        }

        $eventTitle = $event->title;
        $eventId = $event->event_id;

        $participantUserIds = $event->participants()
            ->where('user_id', '!=', $userId)
            ->whereNotNull('user_id')
            ->pluck('user_id');

        DB::transaction(function () use ($event, $participantUserIds, $eventTitle, $eventId) {
            $event->delete();

            foreach ($participantUserIds as $participantUserId) {
                Notification::create([
                    'user_id' => $participantUserId,
                    'type' => 'system',
                    'title' => 'Sự kiện đã bị xóa',
                    'content' => 'Sự kiện "'.$eventTitle.'" đã bị xóa bởi người tổ chức.',
                    'reference_id' => $eventId,
                    'is_read' => false,
                ]);
            }
        });

        return response()->json([
            'message' => 'Xóa sự kiện thành công',
        ], 200);
    }

    /**
     * GET /api/events/{event}/invite - Get (or renew) the invite link/QR data (owner only).
     */
    public function invite(Event $event)
    {
        if ($event->owner_id !== auth()->id()) {
            return response()->json([
                'message' => 'Chỉ người tổ chức mới được xem link mời.',
            ], 403);
        }

        $invitation = Invitation::where('event_id', $event->event_id)
            ->orderByDesc('invitation_id')
            ->first();

        if (! $invitation || $invitation->status !== 'pending' || $invitation->expired_at->isPast()) {
            $invitation = Invitation::create([
                'event_id' => $event->event_id,
                'token' => Str::random(32),
                'expired_at' => now()->addDays(self::INVITE_TTL_DAYS),
                'status' => 'pending',
            ]);
        }

        return response()->json([
            'message' => 'Lấy link mời thành công',
            'data' => [
                'invite_token' => $invitation->token,
                'invite_link' => self::INVITE_LINK_PREFIX.$invitation->token,
                'expired_at' => $invitation->expired_at,
            ],
        ], 200);
    }

    /**
     * POST /api/events/join - Show unclaimed participants for an invite token.
     */
    public function join(Request $request)
    {
        $data = $request->validate([
            'token' => 'required|string',
        ], [
            'token.required' => 'Vui lòng cung cấp mã mời.',
        ]);

        $invitation = $this->validInvitation($data['token']);
        if ($invitation instanceof JsonResponse) {
            return $invitation;
        }

        $event = $invitation->event;

        $unclaimed = $event->participants()
            ->whereNull('user_id')
            ->where('status', 'active')
            ->get(['participant_id', 'display_name']);

        return response()->json([
            'message' => 'Lấy danh sách người tham gia thành công',
            'data' => [
                'event' => [
                    'event_id' => $event->event_id,
                    'title' => $event->title,
                    'icon' => $event->icon,
                ],
                'participants' => $unclaimed,
            ],
        ], 200);
    }

    /**
     * POST /api/events/join/claim - Claim a participant name for the authenticated user.
     */
    public function claim(Request $request)
    {
        $data = $request->validate([
            'token' => 'required|string',
            'participant_id' => 'required|integer',
        ], [
            'token.required' => 'Vui lòng cung cấp mã mời.',
            'participant_id.required' => 'Vui lòng chọn tên của bạn.',
        ]);

        $invitation = $this->validInvitation($data['token']);
        if ($invitation instanceof JsonResponse) {
            return $invitation;
        }

        $user = $request->user();

        $participant = $invitation->event->participants()
            ->where('participant_id', $data['participant_id'])
            ->first();

        if (! $participant) {
            return response()->json([
                'message' => 'Không tìm thấy người tham gia này.',
            ], 404);
        }

        if ($participant->user_id !== null) {
            return response()->json([
                'message' => 'Tên này đã được chọn bởi người khác.',
            ], 409);
        }

        $alreadyJoined = $invitation->event->participants()
            ->where('user_id', $user->id)
            ->where('status', 'active')
            ->exists();

        if ($alreadyJoined) {
            return response()->json([
                'message' => 'Bạn đã tham gia sự kiện này.',
            ], 409);
        }

        DB::transaction(function () use ($participant, $user, $invitation) {
            $participant->update([
                'user_id' => $user->id,
                'display_name' => $user->name,
                'email' => $user->email,
                'avatar' => $user->avatar,
            ]);

            $hasUnclaimed = $invitation->event->participants()
                ->whereNull('user_id')
                ->exists();

            if (! $hasUnclaimed) {
                $invitation->update([
                    'status' => 'accepted',
                    'used_at' => now(),
                ]);
            }
        });

        return response()->json([
            'message' => 'Tham gia sự kiện thành công',
            'data' => [
                'event' => [
                    'event_id' => $invitation->event_id,
                    'title' => $invitation->event->title,
                    'icon' => $invitation->event->icon,
                ],
                'participant' => $participant,
            ],
        ], 200);
    }

    /**
     * Find a valid (pending, not expired) invitation or return an error response.
     */
    private function validInvitation(string $token): Invitation|JsonResponse
    {
        $invitation = Invitation::where('token', $token)->first();

        if (! $invitation) {
            return response()->json([
                'message' => 'Link mời không hợp lệ.',
            ], 400);
        }

        if ($invitation->status !== 'pending') {
            return response()->json([
                'message' => 'Link mời đã được sử dụng xong.',
            ], 400);
        }

        if ($invitation->expired_at->isPast()) {
            return response()->json([
                'message' => 'Link mời đã hết hạn.',
            ], 410);
        }

        return $invitation;
    }
}
