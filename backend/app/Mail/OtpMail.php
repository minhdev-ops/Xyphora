<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class OtpMail extends Mailable
{
    use Queueable, SerializesModels;

    public $otp;
    public $appName;

    public function __construct(string $otp)
    {
        $this->otp = $otp;
        $this->appName = config('app.name', 'Xyphora');
    }

    public function build()
    {
        $otp = $this->otp;
        $appName = $this->appName;

        return $this->subject("Mã OTP đặt lại mật khẩu - {$appName}")
            ->html("
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset='UTF-8'>
            <meta name='viewport' content='width=device-width, initial-scale=1.0'>
        </head>
        <body style='margin:0;padding:0;background-color:#F4FAF6;font-family:Segoe UI,Tahoma,Geneva,Verdana,sans-serif;'>
            <table width='100%' cellpadding='0' cellspacing='0' style='padding:40px 20px;'>
                <tr>
                    <td align='center'>
                        <table width='480' cellpadding='0' cellspacing='0' style='background-color:#FFFFFF;border-radius:20px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,0.08);'>
                            <tr>
                                <td style='background:linear-gradient(135deg,#0F5C43,#2C7A58);padding:40px 32px;text-align:center;'>
                                    <h1 style='color:#FFFFFF;margin:0;font-size:24px;font-weight:700;'>{$appName}</h1>
                                </td>
                            </tr>
                            <tr>
                                <td style='padding:40px 32px;'>
                                    <h2 style='color:#1D1D1D;margin:0 0 16px;font-size:20px;font-weight:700;'>Đặt lại mật khẩu</h2>
                                    <p style='color:#5A7563;margin:0 0 24px;font-size:15px;line-height:1.6;'>
                                        Bạn đã yêu cầu đặt lại mật khẩu. Sử dụng mã OTP bên dưới để tiếp tục:
                                    </p>
                                    <table width='100%' cellpadding='0' cellspacing='0'>
                                        <tr>
                                            <td align='center' style='padding:0 0 24px;'>
                                                <div style='background-color:#F4FAF6;border-radius:16px;padding:20px 32px;display:inline-block;'>
                                                    <span style='font-size:36px;font-weight:800;color:#0F5C43;letter-spacing:8px;font-family:Courier New,monospace;'>{$otp}</span>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                    <p style='color:#8A8A8A;margin:0 0 8px;font-size:13px;text-align:center;'>
                                        Mã OTP có hiệu lực trong <strong style='color:#E53935;'>5 phút</strong>.
                                    </p>
                                    <p style='color:#8A8A8A;margin:0;font-size:13px;text-align:center;'>
                                        Nếu bạn không yêu cầu đặt lại mật khẩu, hãy bỏ qua email này.
                                    </p>
                                </td>
                            </tr>
                            <tr>
                                <td style='padding:24px 32px;background-color:#F4FAF6;text-align:center;border-top:1px solid #E8E8E8;'>
                                    <p style='color:#8A8A8A;margin:0;font-size:12px;'>
                                        © 2026 {$appName}. All rights reserved.
                                    </p>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </body>
        </html>");
    }
}
