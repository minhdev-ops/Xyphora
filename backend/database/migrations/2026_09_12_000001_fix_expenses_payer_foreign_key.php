<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('expenses')) {
            return;
        }

        // 1. Drop FK composite cũ (nếu tồn tại)
        // Tên FK trong SQL gốc: fk_expenses_payer
        try {
            DB::statement('ALTER TABLE `expenses` DROP FOREIGN KEY `fk_expenses_payer`');
        } catch (\Exception $e) {
            // FK có thể không tồn tại hoặc tên khác - ignore
        }

        // Drop index composite cũ nếu còn (nếu có)
        try {
            DB::statement('ALTER TABLE `expenses` DROP INDEX `fk_expenses_payer`');
        } catch (\Exception $e) {
            // ignore
        }

        // 2. Thêm FK đơn giản mới cho payer_id
        Schema::table('expenses', function (Blueprint $table) {
            $table->foreign('payer_id', 'fk_expenses_payer_simple')
                ->references('participant_id')->on('participants')
                ->restrictOnDelete()->cascadeOnUpdate();
        });
    }

    public function down(): void
    {
        if (!Schema::hasTable('expenses')) {
            return;
        }

        // Drop FK mới
        try {
            Schema::table('expenses', function (Blueprint $table) {
                $table->dropForeign('fk_expenses_payer_simple');
            });
        } catch (\Exception $e) {
            // ignore
        }

        // Restore FK composite cũ (nếu cần rollback)
        // Lưu ý: FK composite cần cả event_id và payer_id, và participants phải có PK (event_id, participant_id)
        // Nếu participants không có composite PK này, FK sẽ fail - đây là vấn đề của schema cũ
        try {
            Schema::table('expenses', function (Blueprint $table) {
                $table->foreign(['event_id', 'payer_id'], 'fk_expenses_payer')
                    ->references(['event_id', 'participant_id'])->on('participants')
                    ->restrictOnDelete()->cascadeOnUpdate();
            });
        } catch (\Exception $e) {
            // Nếu rollback fail do schema không tương thích, log error
        }
    }
};