-- ============================================================================
-- Xyphora - Group Expense Sharing (Tricount-like)
-- MySQL 8.0 Schema: 13 tables, foreign keys, indexes, constraints
-- Engine: InnoDB | Charset: utf8mb4 | Collation: utf8mb4_unicode_ci
--
-- FILE NAY PHAN ANH DUNG SCHEMA DA TRIEN KHAI BANG LARAVEL MIGRATIONS
-- (database/migrations/2026_08_06_*). Neu schema tren DB va file nay lech
-- nhau, chay database/design/audit.sql de so sanh.
--
-- Cach chay (DB moi): mysql -u root -p < database/design/schema.sql
-- ============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS refresh_tokens;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS settlements;
DROP TABLE IF EXISTS expense_history;
DROP TABLE IF EXISTS expense_photos;
DROP TABLE IF EXISTS expense_splits;
DROP TABLE IF EXISTS expenses;
DROP TABLE IF EXISTS photos;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS invitations;
DROP TABLE IF EXISTS participants;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS users;

-- ----------------------------------------------------------------------------
-- 1. users
--    LUU Y: khoa chinh la `id` (tuan thu Laravel/Passport). Thiet ke ban dau
--    goi la `user_id`/`full_name` -> map sang `id`/`name` khi trien khai.
-- ----------------------------------------------------------------------------
CREATE TABLE users (
    id                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name              VARCHAR(255)    NOT NULL,
    email             VARCHAR(255)    NOT NULL,
    email_verified_at TIMESTAMP       NULL,
    password          VARCHAR(255)    NOT NULL,
    avatar            VARCHAR(500)    NULL,
    provider          ENUM('email','google','facebook','apple') NOT NULL DEFAULT 'email',
    status            ENUM('active','inactive','banned') NOT NULL DEFAULT 'active',
    remember_token    VARCHAR(100)    NULL,
    created_at        TIMESTAMP       NULL,
    updated_at        TIMESTAMP       NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_users_email (email),
    KEY idx_users_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Nguoi dung he thong';

-- ----------------------------------------------------------------------------
-- 2. events
-- ----------------------------------------------------------------------------
CREATE TABLE events (
    event_id     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    owner_id     BIGINT UNSIGNED NOT NULL,
    title        VARCHAR(150)    NOT NULL,
    description  TEXT            NULL,
    icon         VARCHAR(50)     NULL,
    cover_photo  VARCHAR(500)    NULL,
    currency     CHAR(3)         NOT NULL DEFAULT 'VND',
    start_date   DATE            NULL,
    end_date     DATE            NULL,
    status       ENUM('active','completed','archived') NOT NULL DEFAULT 'active',
    created_at   TIMESTAMP       NULL,
    updated_at   TIMESTAMP       NULL,
    PRIMARY KEY (event_id),
    KEY idx_events_owner (owner_id),
    KEY idx_events_owner_status (owner_id, status),
    KEY idx_events_start_date (start_date),
    CONSTRAINT fk_events_owner FOREIGN KEY (owner_id) REFERENCES users (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_events_dates CHECK (start_date IS NULL OR end_date IS NULL OR end_date >= start_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Nhom chi phi (Event/Trip)';

-- ----------------------------------------------------------------------------
-- 3. participants
--    - UNIQUE(event_id, email): 1 email / 1 nhom
--    - uq_participants_single_owner: functional unique index, dam bao moi
--      event chi co DUNG MOT owner (dong khac owner map NULL nen khong xung dot)
-- ----------------------------------------------------------------------------
CREATE TABLE participants (
    participant_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    event_id       BIGINT UNSIGNED NOT NULL,
    user_id        BIGINT UNSIGNED NULL,
    display_name   VARCHAR(100)    NOT NULL,
    email          VARCHAR(191)    NOT NULL,
    avatar         VARCHAR(500)    NULL,
    role           ENUM('owner','admin','member') NOT NULL DEFAULT 'member',
    joined_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status         ENUM('active','removed','left') NOT NULL DEFAULT 'active',
    PRIMARY KEY (participant_id),
    UNIQUE KEY uq_participants_event_email (event_id, email),
    UNIQUE KEY uq_participants_single_owner (event_id, ((IF(role = 'owner', role, NULL)))),
    KEY idx_participants_user (user_id),
    KEY idx_participants_event_status (event_id, status),
    KEY idx_participants_event_participant (event_id, participant_id),
    CONSTRAINT fk_participants_event FOREIGN KEY (event_id) REFERENCES events (event_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_participants_user FOREIGN KEY (user_id) REFERENCES users (id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Thanh vien trong nhom (bao gom khach khong co tai khoan)';

-- ----------------------------------------------------------------------------
-- 4. invitations
-- ----------------------------------------------------------------------------
CREATE TABLE invitations (
    invitation_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    event_id      BIGINT UNSIGNED NOT NULL,
    token         VARCHAR(64)     NOT NULL,
    expired_at    DATETIME        NOT NULL,
    used_at       DATETIME        NULL,
    status        ENUM('pending','accepted','expired','revoked') NOT NULL DEFAULT 'pending',
    created_at    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (invitation_id),
    UNIQUE KEY uq_invitations_token (token),
    KEY idx_invitations_event (event_id),
    KEY idx_invitations_status (status),
    CONSTRAINT fk_invitations_event FOREIGN KEY (event_id) REFERENCES events (event_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_invitations_used CHECK ((status = 'accepted') = (used_at IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Loi moi thanh vien bang token/link';

-- ----------------------------------------------------------------------------
-- 5. categories
-- ----------------------------------------------------------------------------
CREATE TABLE categories (
    category_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name        VARCHAR(100)    NOT NULL,
    icon        VARCHAR(50)     NULL,
    color       VARCHAR(7)      NOT NULL DEFAULT '#64748b',
    type        ENUM('expense','income') NOT NULL DEFAULT 'expense',
    is_default  TINYINT(1)      NOT NULL DEFAULT 0,
    created_by  BIGINT UNSIGNED NULL,
    PRIMARY KEY (category_id),
    KEY idx_categories_created_by (created_by),
    KEY idx_categories_type (type),
    CONSTRAINT fk_categories_created_by FOREIGN KEY (created_by) REFERENCES users (id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Danh muc chi phi (he thong va tu tao)';

-- ----------------------------------------------------------------------------
-- 6. photos
-- ----------------------------------------------------------------------------
CREATE TABLE photos (
    photo_id    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    link        VARCHAR(500)    NOT NULL,
    mime_type   VARCHAR(50)     NULL,
    size        BIGINT UNSIGNED NULL,
    uploaded_by BIGINT UNSIGNED NOT NULL,
    created_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (photo_id),
    KEY idx_photos_uploaded_by (uploaded_by),
    CONSTRAINT fk_photos_uploaded_by FOREIGN KEY (uploaded_by) REFERENCES users (id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='File anh (hoa don, minh chung)';

-- ----------------------------------------------------------------------------
-- 7. expenses
--    fk_expenses_payer la COMPOSITE FK (event_id, payer_id) -> participants:
--    dam bao payer luon la thanh vien CUA CUNG event voi expense.
-- ----------------------------------------------------------------------------
CREATE TABLE expenses (
    expense_id    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    event_id      BIGINT UNSIGNED NOT NULL,
    created_by    BIGINT UNSIGNED NOT NULL,
    payer_id      BIGINT UNSIGNED NOT NULL,
    category_id   BIGINT UNSIGNED NOT NULL,
    title         VARCHAR(150)    NOT NULL,
    description   TEXT            NULL,
    amount        DECIMAL(15,2)   NOT NULL,
    currency      CHAR(3)         NOT NULL DEFAULT 'VND',
    expense_date  DATE            NOT NULL,
    expense_type  ENUM('expense','income') NOT NULL DEFAULT 'expense',
    split_method  ENUM('equal','exact','percentage','share') NOT NULL DEFAULT 'equal',
    note          VARCHAR(500)    NULL,
    is_deleted    TINYINT(1)      NOT NULL DEFAULT 0,
    created_at    TIMESTAMP       NULL,
    updated_at    TIMESTAMP       NULL,
    PRIMARY KEY (expense_id),
    KEY idx_expenses_event (event_id),
    KEY idx_expenses_event_date (event_id, expense_date),
    KEY idx_expenses_event_visible (event_id, is_deleted),
    KEY idx_expenses_payer (payer_id),
    KEY idx_expenses_category (category_id),
    KEY idx_expenses_created_by (created_by),
    KEY idx_expenses_expense_date (expense_date),
    CONSTRAINT fk_expenses_event FOREIGN KEY (event_id) REFERENCES events (event_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_expenses_created_by FOREIGN KEY (created_by) REFERENCES users (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_expenses_payer FOREIGN KEY (event_id, payer_id)
        REFERENCES participants (event_id, participant_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_expenses_category FOREIGN KEY (category_id) REFERENCES categories (category_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_expenses_amount CHECK (amount > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Chi phi cua nhom';

-- ----------------------------------------------------------------------------
-- 8. expense_splits
--    Khoa chinh TONG HOP (expense_id, participant_id): moi participant xuat
--    hien toi da 1 lan trong 1 expense. Luu y Eloquent khong ho tro composite
--    PK -> model ExpenseSplit truy van bang where() ca 2 khoa.
-- ----------------------------------------------------------------------------
CREATE TABLE expense_splits (
    expense_id     BIGINT UNSIGNED NOT NULL,
    participant_id BIGINT UNSIGNED NOT NULL,
    amount         DECIMAL(15,2)   NOT NULL,
    percentage     DECIMAL(5,2)    NULL,
    share          INT UNSIGNED    NULL,
    status         ENUM('pending','settled') NOT NULL DEFAULT 'pending',
    created_at     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (expense_id, participant_id),
    KEY idx_splits_participant (participant_id),
    KEY idx_splits_status (expense_id, status),
    KEY idx_splits_participant_status (participant_id, status),
    CONSTRAINT fk_splits_expense FOREIGN KEY (expense_id) REFERENCES expenses (expense_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_splits_participant FOREIGN KEY (participant_id) REFERENCES participants (participant_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_splits_amount CHECK (amount > 0),
    CONSTRAINT chk_splits_percentage CHECK (percentage IS NULL OR (percentage >= 0 AND percentage <= 100)),
    CONSTRAINT chk_splits_share CHECK (share IS NULL OR share > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Cach chia chi phi cho tung thanh vien';

-- ----------------------------------------------------------------------------
-- 9. expense_photos (bang lien ket N-N)
-- ----------------------------------------------------------------------------
CREATE TABLE expense_photos (
    expense_id BIGINT UNSIGNED NOT NULL,
    photo_id   BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (expense_id, photo_id),
    KEY idx_expense_photos_photo (photo_id),
    CONSTRAINT fk_expense_photos_expense FOREIGN KEY (expense_id) REFERENCES expenses (expense_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_expense_photos_photo FOREIGN KEY (photo_id) REFERENCES photos (photo_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Lien ket chi phi - anh';

-- ----------------------------------------------------------------------------
-- 10. expense_history
-- ----------------------------------------------------------------------------
CREATE TABLE expense_history (
    history_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    expense_id BIGINT UNSIGNED NOT NULL,
    updated_by BIGINT UNSIGNED NULL,
    field_name VARCHAR(50)      NOT NULL,
    old_value  TEXT             NULL,
    new_value  TEXT             NULL,
    updated_at TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (history_id),
    KEY idx_history_expense (expense_id),
    KEY idx_history_expense_created (expense_id, updated_at),
    KEY idx_history_updated_by (updated_by),
    CONSTRAINT fk_history_expense FOREIGN KEY (expense_id) REFERENCES expenses (expense_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_history_updated_by FOREIGN KEY (updated_by) REFERENCES users (id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Lich su chinh sua chi phi';

-- ----------------------------------------------------------------------------
-- 11. settlements
--    COMPOSITE FK (event_id, from/to_participant) -> participants: dam bao
--    2 ben giao dich LUON thuoc cung event voi settlement.
--    Khong dung ON UPDATE CASCADE o day vi cot nam trong CHECK constraint
--    (MySQL 8 ban error 3823).
-- ----------------------------------------------------------------------------
CREATE TABLE settlements (
    settlement_id    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    event_id         BIGINT UNSIGNED NOT NULL,
    from_participant BIGINT UNSIGNED NOT NULL,
    to_participant   BIGINT UNSIGNED NOT NULL,
    amount           DECIMAL(15,2)   NOT NULL,
    status           ENUM('pending','completed','cancelled') NOT NULL DEFAULT 'pending',
    note             VARCHAR(255)    NULL,
    settled_at       DATETIME        NULL,
    created_at       TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (settlement_id),
    KEY idx_settlements_event (event_id),
    KEY idx_settlements_event_status (event_id, status),
    KEY idx_settlements_from (from_participant),
    KEY idx_settlements_to (to_participant),
    CONSTRAINT fk_settlements_event FOREIGN KEY (event_id) REFERENCES events (event_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_settlements_from FOREIGN KEY (event_id, from_participant)
        REFERENCES participants (event_id, participant_id) ON DELETE RESTRICT,
    CONSTRAINT fk_settlements_to FOREIGN KEY (event_id, to_participant)
        REFERENCES participants (event_id, participant_id) ON DELETE RESTRICT,
    CONSTRAINT chk_settlements_amount CHECK (amount > 0),
    CONSTRAINT chk_settlements_party CHECK (from_participant <> to_participant),
    CONSTRAINT chk_settlements_status CHECK ((status = 'completed') = (settled_at IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Giao dich thanh toan cong no';

-- ----------------------------------------------------------------------------
-- 12. notifications
-- ----------------------------------------------------------------------------
CREATE TABLE notifications (
    notification_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id         BIGINT UNSIGNED NOT NULL,
    type            ENUM('invitation','expense_added','expense_updated','expense_deleted',
                         'settlement_request','settlement_completed','reminder','system') NOT NULL,
    title           VARCHAR(150)    NOT NULL,
    content         TEXT            NULL,
    reference_id    BIGINT UNSIGNED NULL,
    is_read         TINYINT(1)      NOT NULL DEFAULT 0,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (notification_id),
    KEY idx_notifications_user (user_id),
    KEY idx_notifications_user_unread (user_id, is_read),
    KEY idx_notifications_user_unread_created (user_id, is_read, created_at),
    KEY idx_notifications_created (created_at),
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users (id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Thong bao trong app';

-- ----------------------------------------------------------------------------
-- 13. refresh_tokens
-- ----------------------------------------------------------------------------
CREATE TABLE refresh_tokens (
    token_id   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id    BIGINT UNSIGNED NOT NULL,
    token      VARCHAR(255)    NOT NULL,
    expired_at DATETIME        NOT NULL,
    created_at TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (token_id),
    UNIQUE KEY uq_refresh_tokens_token (token),
    KEY idx_refresh_tokens_user (user_id),
    CONSTRAINT fk_refresh_tokens_user FOREIGN KEY (user_id) REFERENCES users (id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Refresh token cho xac thuc';

SET FOREIGN_KEY_CHECKS = 1;
