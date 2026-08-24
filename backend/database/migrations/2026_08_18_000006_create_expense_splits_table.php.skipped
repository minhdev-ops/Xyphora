<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('expense_splits', function (Blueprint $table) {
            $table->foreignId('expense_id');
            $table->foreignId('participant_id');
            $table->decimal('amount', 15, 2);
            $table->decimal('percentage', 5, 2)->nullable();
            $table->unsignedInteger('share')->nullable();
            $table->enum('status', ['pending', 'settled'])->default('pending');
            $table->timestamp('created_at')->nullable(false)->useCurrent();

            $table->primary(['expense_id', 'participant_id']);
            $table->index('participant_id', 'idx_splits_participant');
            $table->index(['expense_id', 'status'], 'idx_splits_status');
            $table->index(['participant_id', 'status'], 'idx_splits_participant_status');

            $table->foreign('expense_id', 'fk_splits_expense')
                ->references('expense_id')->on('expenses')
                ->cascadeOnDelete()->cascadeOnUpdate();
            $table->foreign('participant_id', 'fk_splits_participant')
                ->references('participant_id')->on('participants')
                ->cascadeOnDelete()->cascadeOnUpdate();
        });

        DB::statement('ALTER TABLE `expense_splits` ADD CONSTRAINT `chk_splits_amount` CHECK (`amount` > 0)');
        DB::statement(
            'ALTER TABLE `expense_splits` ADD CONSTRAINT `chk_splits_percentage` '
            . 'CHECK ((`percentage` IS NULL) OR (`percentage` >= 0 AND `percentage` <= 100))'
        );
        DB::statement(
            'ALTER TABLE `expense_splits` ADD CONSTRAINT `chk_splits_share` '
            . 'CHECK ((`share` IS NULL) OR (`share` > 0))'
        );
    }

    public function down(): void
    {
        Schema::dropIfExists('expense_splits');
    }
};