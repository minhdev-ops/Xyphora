<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('expenses', function (Blueprint $table) {
            $table->bigIncrements('expense_id');
            $table->unsignedBigInteger('event_id');
            $table->unsignedBigInteger('created_by');
            $table->unsignedBigInteger('payer_id');
            $table->unsignedBigInteger('category_id');
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
            $table->index('payer_id', 'idx_expenses_payer');
            $table->index('category_id', 'idx_expenses_category');
            $table->index('created_by', 'idx_expenses_created_by');
            $table->index('expense_date', 'idx_expenses_expense_date');

            $table->foreign('event_id', 'fk_expenses_event')
                ->references('event_id')->on('events')
                ->cascadeOnUpdate()->cascadeOnDelete();
            $table->foreign('created_by', 'fk_expenses_created_by')
                ->references('id')->on('users')
                ->cascadeOnUpdate()->restrictOnDelete();
            $table->foreign('payer_id', 'fk_expenses_payer')
                ->references('participant_id')->on('participants')
                ->cascadeOnUpdate()->restrictOnDelete();
            $table->foreign('category_id', 'fk_expenses_category')
                ->references('category_id')->on('categories')
                ->cascadeOnUpdate()->restrictOnDelete();
        });

        DB::statement('ALTER TABLE expenses ADD CONSTRAINT chk_expenses_amount CHECK (amount > 0)');
    }

    public function down(): void
    {
        Schema::dropIfExists('expenses');
    }
};
