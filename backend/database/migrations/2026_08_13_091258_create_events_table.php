<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('events', function (Blueprint $table) {
            $table->id('event_id');
            $table->foreignId('owner_id');
            $table->string('title', 150);
            $table->text('description')->nullable();
            $table->string('icon', 50)->nullable();
            $table->string('cover_photo', 500)->nullable();
            $table->char('currency', 3)->default('VND');
            $table->date('start_date')->nullable();
            $table->date('end_date')->nullable();
            $table->enum('status', ['active', 'completed', 'archived'])->default('active');
            $table->timestamps();

            $table->index('owner_id', 'idx_events_owner');
            $table->index(['owner_id', 'status'], 'idx_events_owner_status');
            $table->index('start_date', 'idx_events_start_date');

            $table->foreign('owner_id', 'fk_events_owner')
                ->references('id')->on('users')
                ->restrictOnDelete()->cascadeOnUpdate();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('events');
    }
};