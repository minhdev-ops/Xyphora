<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

return new class extends Migration
{
    public function up(): void
    {
        // Tạo Personal Access Client cho Passport (chỉ chạy 1 lần)
        if (!DB::table('oauth_clients')->where('personal_access_client', true)->exists()) {
            DB::table('oauth_clients')->insert([
                'id' => Str::uuid()->toString(),
                'owner_type' => null,
                'owner_id' => null,
                'name' => 'Laravel Personal Access Client',
                'secret' => Str::random(40),
                'provider' => null,
                'redirect_uris' => '[]',
                'grant_types' => '["personal_access"]',
                'personal_access_client' => true,
                'password_client' => false,
                'revoked' => false,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        // Tạo Password Grant Client (optional - nếu dùng password grant)
        if (!DB::table('oauth_clients')->where('password_client', true)->exists()) {
            DB::table('oauth_clients')->insert([
                'id' => Str::uuid()->toString(),
                'owner_type' => null,
                'owner_id' => null,
                'name' => 'Laravel Password Grant Client',
                'secret' => Str::random(40),
                'provider' => null,
                'redirect_uris' => '[]',
                'grant_types' => '["password"]',
                'personal_access_client' => false,
                'password_client' => true,
                'revoked' => false,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }

    public function down(): void
    {
        // Xóa các client mặc định khi rollback
        DB::table('oauth_clients')
            ->whereIn('name', ['Laravel Personal Access Client', 'Laravel Password Grant Client'])
            ->delete();
    }
};