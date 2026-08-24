<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('expense_history', function (Blueprint $table) {
            $table->bigIncrements('history_id');
            $table->unsignedBigInteger('expense_id');
            $table->unsignedBigInteger('updated_by')->nullable();
            $table->string('field_name', 50);
            $table->text('old_value')->nullable();
            $table->text('new_value')->nullable();
            $table->timestamp('updated_at')->useCurrent();

            $table->index('expense_id', 'idx_history_expense');
            $table->index(['expense_id', 'updated_at'], 'idx_history_expense_created');
            $table->index('updated_by', 'idx_history_updated_by');

            $table->foreign('expense_id', 'fk_history_expense')
                ->references('expense_id')->on('expenses')
                ->cascadeOnUpdate()->cascadeOnDelete();
            $table->foreign('updated_by', 'fk_history_updated_by')
                ->references('id')->on('users')
                ->cascadeOnUpdate()->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('expense_history');
    }
};
