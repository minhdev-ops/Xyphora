<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('invitations', function (Blueprint $table) {
            $table->id('invitation_id');
            $table->foreignId('event_id');
            $table->string('token', 64);
            $table->dateTime('expired_at');
            $table->dateTime('used_at')->nullable();
            $table->enum('status', ['pending', 'accepted', 'expired', 'revoked'])->default('pending');
            $table->timestamp('created_at')->nullable(false)->useCurrent();

            $table->unique('token', 'uq_invitations_token');
            $table->index('event_id', 'idx_invitations_event');
            $table->index('status', 'idx_invitations_status');

            $table->foreign('event_id', 'fk_invitations_event')
                ->references('event_id')->on('events')
                ->cascadeOnDelete()->cascadeOnUpdate();
        });

        DB::statement(
            "ALTER TABLE `invitations` ADD CONSTRAINT `chk_invitations_used` "
            . "CHECK ((`status` = 'accepted') = (`used_at` IS NOT NULL))"
        );
    }

    public function down(): void
    {
        Schema::dropIfExists('invitations');
    }
};