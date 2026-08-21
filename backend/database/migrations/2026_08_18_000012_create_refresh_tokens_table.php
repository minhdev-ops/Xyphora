<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('refresh_tokens', function (Blueprint $table) {
            $table->id('token_id');
            $table->foreignId('user_id');
            $table->string('token', 255);
            $table->dateTime('expired_at');
            $table->timestamp('created_at')->nullable(false)->useCurrent();

            $table->unique('token', 'uq_refresh_tokens_token');
            $table->index('user_id', 'idx_refresh_tokens_user');

            $table->foreign('user_id', 'fk_refresh_tokens_user')
                ->references('id')->on('users')
                ->cascadeOnDelete()->cascadeOnUpdate();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('refresh_tokens');
    }
};