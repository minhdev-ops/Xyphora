<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $notifications = Notification::where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->paginate($request->input('per_page', 20));

        $data = $notifications->map(function (Notification $n) {
            return [
                'notification_id' => $n->notification_id,
                'type' => $n->type,
                'title' => $n->title,
                'content' => $n->content,
                'reference_id' => $n->reference_id,
                'is_read' => (bool) $n->is_read,
                'created_at' => $n->created_at?->toDateTimeString(),
            ];
        });

        return response()->json([
            'message' => 'Lấy danh sách thông báo thành công',
            'data' => $data,
            'meta' => [
                'current_page' => $notifications->currentPage(),
                'per_page' => $notifications->perPage(),
                'total' => $notifications->total(),
                'last_page' => $notifications->lastPage(),
            ],
        ]);
    }

    public function markAsRead(Request $request, int $notification): JsonResponse
    {
        $user = $request->user();

        $notification = Notification::where('notification_id', $notification)
            ->where('user_id', $user->id)
            ->first();

        if (! $notification) {
            return response()->json([
                'message' => 'Thông báo không tồn tại.',
            ], 404);
        }

        $notification->update(['is_read' => true]);

        return response()->json([
            'message' => 'Đã đánh dấu là đã đọc',
        ]);
    }

    public function markAllAsRead(Request $request): JsonResponse
    {
        $user = $request->user();

        Notification::where('user_id', $user->id)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return response()->json([
            'message' => 'Đã đánh dấu tất cả thông báo là đã đọc',
        ]);
    }

    public function destroy(Request $request, int $notification): JsonResponse
    {
        $user = $request->user();

        $notification = Notification::where('notification_id', $notification)
            ->where('user_id', $user->id)
            ->first();

        if (! $notification) {
            return response()->json([
                'message' => 'Thông báo không tồn tại.',
            ], 404);
        }

        $notification->delete();

        return response()->json([
            'message' => 'Xóa thông báo thành công',
        ]);
    }

    public function unreadCount(Request $request): JsonResponse
    {
        $user = $request->user();

        $count = Notification::where('user_id', $user->id)
            ->where('is_read', false)
            ->count();

        return response()->json([
            'data' => ['unread_count' => $count],
        ]);
    }
}
