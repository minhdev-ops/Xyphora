<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    /**
     * Get the current user profile.
     */
    public function profile(Request $request)
    {
        return response()->json([
            'status' => 'success',
            'data' => $request->user(),
        ]);
    }

    /**
     * Update personal information (avatar, name).
     */
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'name' => 'nullable|string|max:255',
            'avatar' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048', // 2MB Max
        ]);

        if ($request->has('name')) {
            $user->name = $request->name;
        }

        if ($request->hasFile('avatar')) {
            // Delete old avatar if exists and not default
            if ($user->avatar && Storage::disk('public')->exists(str_replace('/storage/', '', $user->avatar))) {
                Storage::disk('public')->delete(str_replace('/storage/', '', $user->avatar));
            }

            $path = $request->file('avatar')->store('avatars', 'public');
            $user->avatar = '/storage/' . $path;
        }

        $user->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Profile updated successfully',
            'data' => $user,
        ]);
    }

    /**
     * Update user settings (language, notifications_enabled).
     */
    public function updateSettings(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'language' => ['nullable', 'string', Rule::in(['en', 'vi'])], // Assuming en and vi are supported
            'notifications_enabled' => 'nullable|boolean',
        ]);

        if ($request->has('language')) {
            $user->language = $request->language;
        }

        if ($request->has('notifications_enabled')) {
            $user->notifications_enabled = $request->notifications_enabled;
        }

        $user->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Settings updated successfully',
            'data' => $user,
        ]);
    }
}
