<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use App\Mail\OtpMail;

class ForgotPasswordController extends Controller
{
    public function sendOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ], [
            'email.required' => 'Vui lòng nhập email.',
            'email.email' => 'Định dạng email không hợp lệ.',
        ]);

        $user = \App\Models\User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'message' => 'Email này chưa được đăng ký.'
            ], 404);
        }

        $otp = str_pad(random_int(100000, 999999), 6, '0', STR_PAD_LEFT);
        $expiresAt = now()->addMinutes(5);

        DB::table('password_resets')->updateOrInsert(
            ['email' => $request->email],
            [
                'token' => Str::random(60),
                'otp' => $otp,
                'expires_at' => $expiresAt,
                'created_at' => now(),
            ]
        );

        // Gửi OTP qua email
        try {
            Mail::to($user->email)->send(new OtpMail($otp));
        } catch (\Exception $e) {
            \Log::error('Mail error: ' . $e->getMessage());
            return response()->json([
                'message' => 'Không thể gửi email. Vui lòng thử lại sau.'
            ], 500);
        }

        return response()->json([
            'message' => 'Mã OTP đã được gửi đến email của bạn.',
        ]);
    }

    public function resetPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp' => 'required|string|size:6',
            'password' => 'required|string|min:8|confirmed',
        ], [
            'email.required' => 'Vui lòng nhập email.',
            'email.email' => 'Định dạng email không hợp lệ.',
            'otp.required' => 'Vui lòng nhập mã OTP.',
            'otp.size' => 'Mã OTP phải có 6 chữ số.',
            'password.required' => 'Vui lòng nhập mật khẩu mới.',
            'password.min' => 'Mật khẩu phải có ít nhất 8 ký tự.',
            'password.confirmed' => 'Xác nhận mật khẩu không khớp.',
        ]);

        $resetRecord = DB::table('password_resets')
            ->where('email', $request->email)
            ->where('otp', $request->otp)
            ->first();

        if (!$resetRecord) {
            return response()->json([
                'message' => 'Mã OTP không đúng.'
            ], 400);
        }

        if ($resetRecord->expires_at && now()->gt($resetRecord->expires_at)) {
            return response()->json([
                'message' => 'Mã OTP đã hết hạn. Vui lòng yêu cầu mã mới.'
            ], 400);
        }

        $user = \App\Models\User::where('email', $request->email)->first();
        if (!$user) {
            return response()->json([
                'message' => 'Không tìm thấy tài khoản.'
            ], 404);
        }

        $user->update(['password' => Hash::make($request->password)]);

        DB::table('password_resets')->where('email', $request->email)->delete();

        return response()->json([
            'message' => 'Đặt lại mật khẩu thành công. Vui lòng đăng nhập lại.'
        ]);
    }
}
