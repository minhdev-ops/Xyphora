<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Composite FK chong du lieu "loan event":
     *
     * Van de phat hien luc audit:
     *   FK don (expenses.payer_id -> participants.participant_id) chi kiem tra
     *   doi tuong tON TAI, nhung KHONG kiem tra payer co thuoc CUNG event voi
     *   expense hay khong => co the ghi expense event A nhung payer event B.
     *
     * Giai phap: cho the hien FK tong hop (event_id, participant_id) de MySQL
     * tu dong dam bao payer/from/to luon nam trong DUNG event.
     *
     *     expenses   FK (event_id, payer_id)
     *              -> participants (event_id, participant_id)
     *     settlements FK (event_id, from_participant)   -> participants (...)
     *     settlements FK (event_id, to_participant)     -> participants (...)
     *
     * Luu y: cac FK nay chi dung ON DELETE RESTRICT (KHONG dung CASCADE/UPDATE
     * action) vi cot cung nam trong CHECK constraint (MySQL 8 ban error 3823).
     */
    public function up(): void
    {
        // 1. Index con tren participants de composite FK co the tham chieu
        DB::statement('ALTER TABLE participants
                       ADD INDEX idx_participants_event_participant (event_id, participant_id)');

        // 2. expenses: thay FK don (payer_id) bang composite (event_id, payer_id)
        DB::statement('ALTER TABLE expenses DROP FOREIGN KEY fk_expenses_payer');
        DB::statement('ALTER TABLE expenses DROP INDEX idx_expenses_payer');
        DB::statement('ALTER TABLE expenses
                       ADD INDEX idx_expenses_payer (payer_id)'); //  giu index phuc vu truy van "toi da chi"
        DB::statement('ALTER TABLE expenses
                       ADD CONSTRAINT fk_expenses_payer
                       FOREIGN KEY (event_id, payer_id) REFERENCES participants (event_id, participant_id)
                       ON DELETE RESTRICT ON UPDATE CASCADE');

        // 3. settlements: thay 2 FK don bang composite
        DB::statement('ALTER TABLE settlements DROP FOREIGN KEY fk_settlements_from');
        DB::statement('ALTER TABLE settlements DROP FOREIGN KEY fk_settlements_to');
        DB::statement('ALTER TABLE settlements
                       ADD CONSTRAINT fk_settlements_from
                       FOREIGN KEY (event_id, from_participant) REFERENCES participants (event_id, participant_id)
                       ON DELETE RESTRICT');
        DB::statement('ALTER TABLE settlements
                       ADD CONSTRAINT fk_settlements_to
                       FOREIGN KEY (event_id, to_participant) REFERENCES participants (event_id, participant_id)
                       ON DELETE RESTRICT');
    }

    public function down(): void
    {
        // Tra ve FK don nhu thiet ke ban dau
        DB::statement('ALTER TABLE settlements DROP FOREIGN KEY fk_settlements_from');
        DB::statement('ALTER TABLE settlements DROP FOREIGN KEY fk_settlements_to');
        DB::statement('ALTER TABLE settlements ADD CONSTRAINT fk_settlements_from
                       FOREIGN KEY (from_participant) REFERENCES participants (participant_id)
                       ON DELETE RESTRICT');
        DB::statement('ALTER TABLE settlements ADD CONSTRAINT fk_settlements_to
                       FOREIGN KEY (to_participant) REFERENCES participants (participant_id)
                       ON DELETE RESTRICT');

        DB::statement('ALTER TABLE expenses DROP FOREIGN KEY fk_expenses_payer');
        DB::statement('ALTER TABLE expenses ADD CONSTRAINT fk_expenses_payer
                       FOREIGN KEY (payer_id) REFERENCES participants (participant_id)
                       ON DELETE RESTRICT ON UPDATE CASCADE');

        DB::statement('ALTER TABLE participants DROP INDEX idx_participants_event_participant');
    }
};
