<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Cac rang buoc CHECK va index phong thu bo sung sau audit:
     *
     * 1. chk_splits_amount        - phan chia cua expense phai duong
     * 2. uq_participants_single_owner - mot event chi duoc phep co MOT owner
     *    (functional unique index: cac dong khong phai owner map sang NULL,
     *     khong trung nhau; dong owner map sang 'owner' => trung thi bi chan)
     * 3. idx_splits_participant_status - truy van "cac khoan con no cua toi"
     * 4. idx_notifications_user_unread_created - phan trang thong bao chua doc
     */
    public function up(): void
    {
        DB::statement('ALTER TABLE expense_splits ADD CONSTRAINT chk_splits_amount CHECK (amount > 0)');

        DB::statement("CREATE UNIQUE INDEX uq_participants_single_owner
                       ON participants (event_id, ((IF(role = 'owner', role, NULL))))");

        DB::statement('ALTER TABLE expense_splits
                       ADD INDEX idx_splits_participant_status (participant_id, status)');

        DB::statement('ALTER TABLE notifications
                       ADD INDEX idx_notifications_user_unread_created (user_id, is_read, created_at)');
    }

    public function down(): void
    {
        DB::statement('ALTER TABLE expense_splits DROP CONSTRAINT chk_splits_amount');
        DB::statement('ALTER TABLE participants DROP INDEX uq_participants_single_owner');
        DB::statement('ALTER TABLE expense_splits DROP INDEX idx_splits_participant_status');
        DB::statement('ALTER TABLE notifications DROP INDEX idx_notifications_user_unread_created');
    }
};
