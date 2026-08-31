<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    /**
     * Get the list of notifications for the current user.
     * Optionally filter by type (e.g. reminder, expense_added, etc).
     */
    public function index(Request $request)
    {
        $user = $request->user();

        $query = Notification::where('user_id', $user->id);

        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        // Return latest notifications first
        $notifications = $query->orderBy('created_at', 'desc')->get();

        return response()->json([
            'status' => 'success',
            'data' => $notifications,
        ]);
    }

    /**
     * Mark a specific notification as read.
     */
    public function markAsRead(Request $request, $id)
    {
        $user = $request->user();

        $notification = Notification::where('user_id', $user->id)
            ->where('notification_id', $id)
            ->first();

        if (!$notification) {
            return response()->json([
                'status' => 'error',
                'message' => 'Notification not found',
            ], 404);
        }

        $notification->is_read = true;
        $notification->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Notification marked as read',
            'data' => $notification,
        ]);
    }
}
