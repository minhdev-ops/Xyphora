<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Chuyển toàn bộ bảng cũ sang InnoDB + utf8mb4.
     *
     * Lý do:
     * - MyISAM khong ho tro FOREIGN KEY => moi FK tro toi bang do se loi 1824
     *   ("Failed to open the referenced table").
     * - utf8mb3 la charset cu: khong luu duoc emoji, va khi JOIN voi cac bang moi
     *   (utf8mb4) MySQL phai doi charset ngam dinh => query cham, so sanh lech.
     *
     * Chuyen doi khong pha huy du lieu (chi doi ENGINE va CHARSET).
     */
    public function up(): void
    {
        $tables = [
            'users',
            'password_resets',
            'personal_access_tokens',
            'oauth_auth_codes',
            'oauth_access_tokens',
            'oauth_refresh_tokens',
            'oauth_clients',
            'oauth_device_codes',
            'failed_jobs',
            'migrations',
        ];

        foreach ($tables as $table) {
            if (! Schema::hasTable($table)) {
                continue;
            }

            // 2 buoc rieng de tranh loi 1031:
            // buoc 1: doi ENGINE + ROW_FORMAT (mot so bang cu dung ROW_FORMAT=FIXED
            //         cua MyISAM, InnoDB khong ho tro, phai bo di)
            // buoc 2: CONVERT TO CHARACTER SET (tao temp table voi cau hinh moi)
            DB::statement(
                "ALTER TABLE `{$table}` ENGINE = InnoDB, ROW_FORMAT = DYNAMIC"
            );
            DB::statement(
                "ALTER TABLE `{$table}` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
            );
        }
    }

    public function down(): void
    {
        // Khong the dao nguoc an toan: quay lai MyISAM/utf8mb3 se tai tao loi FK
        // va mat kha nang luu emoji. Giu nguyen trang thai InnoDB/utf8mb4.
    }
};
