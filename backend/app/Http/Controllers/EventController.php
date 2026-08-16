<?php

namespace App\Http\Controllers;

use App\Models\Event;
use App\Models\Notification;
use App\Models\Participant;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class EventController extends Controller
{
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
            ->withCount('participants')
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
        ], [
            'title.required' => 'Vui lòng nhập tên sự kiện.',
            'title.max' => 'Tên sự kiện không được vượt quá 150 ký tự.',
            'currency.size' => 'Mã tiền tệ phải có 3 ký tự.',
            'start_date.date' => 'Ngày bắt đầu không hợp lệ.',
            'end_date.date' => 'Ngày kết thúc không hợp lệ.',
            'end_date.after_or_equal' => 'Ngày kết thúc phải sau hoặc bằng ngày bắt đầu.',
            'status.in' => 'Trạng thái sự kiện không hợp lệ.',
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

            return $event;
        });

        $event->load('owner:id,name,email,avatar', 'participants');

        return response()->json([
            'message' => 'Tạo sự kiện thành công',
            'data' => $event,
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
        ], [
            'title.required' => 'Vui lòng nhập tên sự kiện.',
            'title.max' => 'Tên sự kiện không được vượt quá 150 ký tự.',
            'currency.size' => 'Mã tiền tệ phải có 3 ký tự.',
            'start_date.date' => 'Ngày bắt đầu không hợp lệ.',
            'end_date.date' => 'Ngày kết thúc không hợp lệ.',
            'end_date.after_or_equal' => 'Ngày kết thúc phải sau hoặc bằng ngày bắt đầu.',
            'status.in' => 'Trạng thái sự kiện không hợp lệ.',
        ]);

        $event->update($data);

        return response()->json([
            'message' => 'Cập nhật sự kiện thành công',
            'data' => $event,
        ], 200);
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
}
