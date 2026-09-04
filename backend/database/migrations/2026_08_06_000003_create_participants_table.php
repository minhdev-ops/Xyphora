<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('participants', function (Blueprint $table) {
            $table->bigIncrements('participant_id');
            $table->unsignedBigInteger('event_id');
            $table->unsignedBigInteger('user_id')->nullable();
            $table->string('display_name', 100);
            $table->string('email', 191);
            $table->string('avatar', 500)->nullable();
            $table->enum('role', ['owner', 'admin', 'member'])->default('member');
            $table->dateTime('joined_at')->useCurrent();
            $table->enum('status', ['active', 'removed', 'left'])->default('active');

            $table->unique(['event_id', 'email'], 'uq_participants_event_email');
            $table->index('user_id', 'idx_participants_user');
            $table->index(['event_id', 'status'], 'idx_participants_event_status');

            $table->foreign('event_id', 'fk_participants_event')
                ->references('event_id')->on('events')
                ->cascadeOnUpdate()->cascadeOnDelete();
            $table->foreign('user_id', 'fk_participants_user')
                ->references('id')->on('users')
                ->cascadeOnUpdate()->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('participants');
    }
};
