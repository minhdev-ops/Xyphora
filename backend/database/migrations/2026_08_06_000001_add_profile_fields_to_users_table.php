<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('avatar', 500)->nullable()->after('password');
            $table->enum('provider', ['email', 'google', 'facebook', 'apple'])->default('email')->after('avatar');
            $table->enum('status', ['active', 'inactive', 'banned'])->default('active')->after('provider');
            $table->index('status', 'idx_users_status');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex('idx_users_status');
            $table->dropColumn(['status', 'provider', 'avatar']);
        });
    }
};
