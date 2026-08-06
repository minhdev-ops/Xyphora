<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('settlements', function (Blueprint $table) {
            $table->bigIncrements('settlement_id');
            $table->unsignedBigInteger('event_id');
            $table->unsignedBigInteger('from_participant');
            $table->unsignedBigInteger('to_participant');
            $table->decimal('amount', 15, 2);
            $table->enum('status', ['pending', 'completed', 'cancelled'])->default('pending');
            $table->string('note', 255)->nullable();
            $table->dateTime('settled_at')->nullable();
            $table->timestamp('created_at')->useCurrent();

            $table->index('event_id', 'idx_settlements_event');
            $table->index(['event_id', 'status'], 'idx_settlements_event_status');
            $table->index('from_participant', 'idx_settlements_from');
            $table->index('to_participant', 'idx_settlements_to');

            $table->foreign('event_id', 'fk_settlements_event')
                ->references('event_id')->on('events')
                ->cascadeOnUpdate()->cascadeOnDelete();
            $table->foreign('from_participant', 'fk_settlements_from')
                ->references('participant_id')->on('participants')
                ->restrictOnDelete();
            $table->foreign('to_participant', 'fk_settlements_to')
                ->references('participant_id')->on('participants')
                ->restrictOnDelete();
        });

        DB::statement('ALTER TABLE settlements ADD CONSTRAINT chk_settlements_amount CHECK (amount > 0)');
        DB::statement('ALTER TABLE settlements ADD CONSTRAINT chk_settlements_party CHECK (from_participant <> to_participant)');
        DB::statement('ALTER TABLE settlements ADD CONSTRAINT chk_settlements_status CHECK ((status = \'completed\') = (settled_at IS NOT NULL))');
    }

    public function down(): void
    {
        Schema::dropIfExists('settlements');
    }
};
