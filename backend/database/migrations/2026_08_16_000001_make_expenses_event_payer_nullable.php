<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('expenses', function (Blueprint $table) {
            $table->dropForeign('fk_expenses_event');
            $table->dropForeign('fk_expenses_payer');
            $table->dropIndex('idx_expenses_event');
            $table->dropIndex('idx_expenses_event_date');
            $table->dropIndex('idx_expenses_event_visible');
            $table->dropIndex('idx_expenses_payer');

            $table->unsignedBigInteger('event_id')->nullable()->change();
            $table->unsignedBigInteger('payer_id')->nullable()->change();

            $table->index('event_id', 'idx_expenses_event');
            $table->index(['event_id', 'expense_date'], 'idx_expenses_event_date');
            $table->index(['event_id', 'is_deleted'], 'idx_expenses_event_visible');
            $table->index('payer_id', 'idx_expenses_payer');
            $table->foreign('event_id', 'fk_expenses_event')
                ->references('event_id')->on('events')
                ->cascadeOnUpdate()->cascadeOnDelete();
            $table->foreign('payer_id', 'fk_expenses_payer')
                ->references('participant_id')->on('participants')
                ->cascadeOnUpdate()->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('expenses', function (Blueprint $table) {
            $table->dropForeign('fk_expenses_event');
            $table->dropForeign('fk_expenses_payer');
            $table->dropIndex('idx_expenses_event');
            $table->dropIndex('idx_expenses_event_date');
            $table->dropIndex('idx_expenses_event_visible');
            $table->dropIndex('idx_expenses_payer');

            $table->unsignedBigInteger('event_id')->nullable(false)->change();
            $table->unsignedBigInteger('payer_id')->nullable(false)->change();

            $table->index('event_id', 'idx_expenses_event');
            $table->index(['event_id', 'expense_date'], 'idx_expenses_event_date');
            $table->index(['event_id', 'is_deleted'], 'idx_expenses_event_visible');
            $table->index('payer_id', 'idx_expenses_payer');
            $table->foreign('event_id', 'fk_expenses_event')
                ->references('event_id')->on('events')
                ->cascadeOnUpdate()->cascadeOnDelete();
            $table->foreign('payer_id', 'fk_expenses_payer')
                ->references('participant_id')->on('participants')
                ->cascadeOnUpdate()->restrictOnDelete();
        });
    }
};
