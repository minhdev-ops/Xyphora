<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notifications', function (Blueprint $table) {
            $table->id('notification_id');
            $table->foreignId('user_id');
            $table->enum('type', [
                'invitation',
                'expense_added',
                'expense_updated',
                'expense_deleted',
                'settlement_request',
                'settlement_completed',
                'reminder',
                'system',
            ]);
            $table->string('title', 150);
            $table->text('content')->nullable();
            $table->unsignedBigInteger('reference_id')->nullable();
            $table->boolean('is_read')->default(false);
            $table->timestamp('created_at')->nullable(false)->useCurrent();

            $table->index('user_id', 'idx_notifications_user');
            $table->index(['user_id', 'is_read'], 'idx_notifications_user_unread');
            $table->index('created_at', 'idx_notifications_created');
            $table->index(['user_id', 'is_read', 'created_at'], 'idx_notifications_user_unread_created');

            $table->foreign('user_id', 'fk_notifications_user')
                ->references('id')->on('users')
                ->cascadeOnDelete()->cascadeOnUpdate();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};