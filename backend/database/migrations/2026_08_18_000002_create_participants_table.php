<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('participants', function (Blueprint $table) {
            $table->id('participant_id');
            $table->foreignId('event_id');
            $table->foreignId('user_id')->nullable();
            $table->string('display_name', 100);
            $table->string('email', 191);
            $table->string('avatar', 500)->nullable();
            $table->enum('role', ['owner', 'admin', 'member'])->default('member');
            $table->dateTime('joined_at')->nullable(false)->useCurrent();
            $table->enum('status', ['active', 'removed', 'left'])->default('active');

            $table->unique(['event_id', 'email'], 'uq_participants_event_email');
            $table->unique(['event_id', 'participant_id'], 'uq_participants_event_participant');
            $table->index('user_id', 'idx_participants_user');
            $table->index(['event_id', 'status'], 'idx_participants_event_status');

            $table->foreign('event_id', 'fk_participants_event')
                ->references('event_id')->on('events')
                ->cascadeOnDelete()->cascadeOnUpdate();
            $table->foreign('user_id', 'fk_participants_user')
                ->references('id')->on('users')
                ->nullOnDelete()->cascadeOnUpdate();
        });

        DB::statement(
            "ALTER TABLE `participants` ADD UNIQUE `uq_participants_single_owner` "
            . "(`event_id`, (IF(`role` = 'owner', `role`, NULL)))"
        );
    }

    public function down(): void
    {
        DB::statement('ALTER TABLE `participants` DROP INDEX `uq_participants_single_owner`');
        Schema::dropIfExists('participants');
    }
};