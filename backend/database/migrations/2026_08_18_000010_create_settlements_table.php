<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('settlements', function (Blueprint $table) {
            $table->id('settlement_id');
            $table->foreignId('event_id');
            $table->foreignId('from_participant');
            $table->foreignId('to_participant');
            $table->decimal('amount', 15, 2);
            $table->enum('status', ['pending', 'completed', 'cancelled'])->default('pending');
            $table->string('note', 255)->nullable();
            $table->dateTime('settled_at')->nullable();
            $table->timestamp('created_at')->nullable(false)->useCurrent();

            $table->index('event_id', 'idx_settlements_event');
            $table->index(['event_id', 'status'], 'idx_settlements_event_status');
            $table->index('from_participant', 'idx_settlements_from');
            $table->index('to_participant', 'idx_settlements_to');
            $table->index(['event_id', 'from_participant'], 'idx_settlements_event_from');
            $table->index(['event_id', 'to_participant'], 'idx_settlements_event_to');

            $table->foreign('event_id', 'fk_settlements_event')
                ->references('event_id')->on('events')
                ->cascadeOnDelete()->cascadeOnUpdate();
            $table->foreign('from_participant', 'fk_settlements_from')
                ->references('participant_id')->on('participants')
                ->restrictOnDelete()->cascadeOnUpdate();
            $table->foreign('to_participant', 'fk_settlements_to')
                ->references('participant_id')->on('participants')
                ->restrictOnDelete()->cascadeOnUpdate();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('settlements');
    }
};