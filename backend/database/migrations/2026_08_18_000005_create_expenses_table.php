<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('expenses', function (Blueprint $table) {
            $table->id('expense_id');
            $table->foreignId('event_id');
            $table->foreignId('created_by');
            $table->foreignId('payer_id');
            $table->foreignId('category_id');
            $table->string('title', 150);
            $table->text('description')->nullable();
            $table->decimal('amount', 15, 2);
            $table->char('currency', 3)->default('VND');
            $table->date('expense_date');
            $table->enum('expense_type', ['expense', 'income'])->default('expense');
            $table->enum('split_method', ['equal', 'exact', 'percentage', 'share'])->default('equal');
            $table->string('note', 500)->nullable();
            $table->boolean('is_deleted')->default(false);
            $table->timestamps();

            $table->index('event_id', 'idx_expenses_event');
            $table->index(['event_id', 'expense_date'], 'idx_expenses_event_date');
            $table->index(['event_id', 'is_deleted'], 'idx_expenses_event_visible');
            $table->index('category_id', 'idx_expenses_category');
            $table->index('created_by', 'idx_expenses_created_by');
            $table->index('expense_date', 'idx_expenses_expense_date');
            $table->index('payer_id', 'idx_expenses_payer');
            $table->index(['event_id', 'payer_id'], 'idx_expenses_payer_event');

            $table->foreign('event_id', 'fk_expenses_event')
                ->references('event_id')->on('events')
                ->cascadeOnDelete()->cascadeOnUpdate();
            $table->foreign('created_by', 'fk_expenses_created_by')
                ->references('id')->on('users')
                ->restrictOnDelete()->cascadeOnUpdate();
            $table->foreign('payer_id', 'fk_expenses_payer')
                ->references('participant_id')->on('participants')
                ->restrictOnDelete()->cascadeOnUpdate();
            $table->foreign('category_id', 'fk_expenses_category')
                ->references('category_id')->on('categories')
                ->restrictOnDelete()->cascadeOnUpdate();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('expenses');
    }
};