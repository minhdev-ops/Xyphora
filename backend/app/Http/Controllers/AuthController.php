<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Str;
use App\Mail\OtpMail;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8',
        ], [
            'name.required' => 'Vui lòng nhập họ và tên.',
            'email.required' => 'Vui lòng nhập email.',
            'email.email' => 'Định dạng email không hợp lệ.',
            'email.unique' => 'Email này đã được đăng ký, vui lòng sử dụng email khác.',
            'password.required' => 'Vui lòng nhập mật khẩu.',
            'password.min' => 'Mật khẩu phải có ít nhất 8 ký tự.',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Đăng ký thành công',
            'data' => $user,
            'access_token' => $token,
            'token_type' => 'Bearer',
        ], 201);
    }

    public function login(Request $request)
    {
        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'message' => 'Email hoặc mật khẩu không chính xác'
            ], 401);
        }

        $user = User::where('email', $request->email)->firstOrFail();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Đăng nhập thành công',
            'data' => $user,
            'access_token' => $token,
            'token_type' => 'Bearer',
        ]);
    }

    public function logout(Request $request)
    {
        $token = $request->user()->currentAccessToken();

        if ($token) {
            $token->delete();
        }

        return response()->json([
            'message' => 'Đã đăng xuất thành công'
        ]);
    }

    public function sendOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ], [
            'email.required' => 'Vui lòng nhập email.',
            'email.email' => 'Định dạng email không hợp lệ.',
        ]);

        $email = strtolower($request->email);
        $rateLimitKey = 'otp_send:' . $email;

        if (RateLimiter::tooManyAttempts($rateLimitKey, 3)) {
            $seconds = RateLimiter::availableIn($rateLimitKey);
            return response()->json([
                'message' => 'Bạn đã yêu cầu quá nhiều lần. Vui lòng thử lại sau ' . $seconds . ' giây.'
            ], 429);
        }

        $user = User::where('email', $email)->first();

        if (!$user) {
            return response()->json([
                'message' => 'Nếu email tồn tại, mã OTP đã được gửi.'
            ]);
        }

        $otp = str_pad(random_int(100000, 999999), 6, '0', STR_PAD_LEFT);
        $expiresAt = now()->addMinutes(5);

        DB::table('password_resets')->updateOrInsert(
            ['email' => $email],
            [
                'token' => Str::random(60),
                'otp' => Hash::make($otp),
                'expires_at' => $expiresAt,
                'created_at' => now(),
            ]
        );

        RateLimiter::hit($rateLimitKey, 60);

        try {
            Mail::to($user->email)->send(new OtpMail($otp));
        } catch (\Exception $e) {
            \Log::error('Mail error: ' . $e->getMessage());
            return response()->json([
                'message' => 'Không thể gửi email. Vui lòng thử lại sau.'
            ], 500);
        }

        return response()->json([
            'message' => 'Nếu email tồn tại, mã OTP đã được gửi.',
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

        $rateLimitKey = 'otp_reset:' . $request->email;

        if (RateLimiter::tooManyAttempts($rateLimitKey, 5)) {
            $seconds = RateLimiter::availableIn($rateLimitKey);
            return response()->json([
                'message' => 'Bạn đã nhập sai quá nhiều lần. Vui lòng thử lại sau ' . $seconds . ' giây.'
            ], 429);
        }

        $resetRecord = DB::table('password_resets')
            ->where('email', $request->email)
            ->first();

        if (!$resetRecord || !Hash::check($request->otp, $resetRecord->otp)) {
            RateLimiter::hit($rateLimitKey, 300);
            return response()->json([
                'message' => 'Mã OTP không đúng.'
            ], 400);
        }

        if ($resetRecord->expires_at && now()->gt($resetRecord->expires_at)) {
            return response()->json([
                'message' => 'Mã OTP đã hết hạn. Vui lòng yêu cầu mã mới.'
            ], 400);
        }

        $user = User::where('email', $request->email)->first();
        if (!$user) {
            return response()->json([
                'message' => 'Không tìm thấy tài khoản.'
            ], 404);
        }

        $user->update(['password' => Hash::make($request->password)]);

        DB::table('password_resets')->where('email', $request->email)->delete();
        RateLimiter::clear($rateLimitKey);

        return response()->json([
            'message' => 'Đặt lại mật khẩu thành công. Vui lòng đăng nhập lại.'
        ]);
    }
}
