<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('expense_payers', function (Blueprint $table) {
            $table->unsignedBigInteger('expense_id');
            $table->unsignedBigInteger('participant_id');
            $table->decimal('amount', 15, 2);
            $table->timestamp('created_at')->useCurrent();

            $table->primary(['expense_id', 'participant_id']);
            $table->index('participant_id', 'idx_payers_participant');

            $table->foreign('expense_id', 'fk_payers_expense')
                ->references('expense_id')->on('expenses')
                ->cascadeOnUpdate()->cascadeOnDelete();
            $table->foreign('participant_id', 'fk_payers_participant')
                ->references('participant_id')->on('participants')
                ->cascadeOnUpdate()->cascadeOnDelete();
        });

        // Backfill du lieu cu: moi expense co payer_id duoc gan 1 dong payer tuong ung
        DB::statement(
            'INSERT INTO expense_payers (expense_id, participant_id, amount, created_at) '
            .'SELECT expense_id, payer_id, amount, NOW() FROM expenses WHERE payer_id IS NOT NULL'
        );
    }

    public function down(): void
    {
        Schema::dropIfExists('expense_payers');
    }
};