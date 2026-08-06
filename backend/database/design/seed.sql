-- ============================================================================
-- Xyphora - Seed data (du lieu mau nhat quan)
-- Lua chay: mysql -u root -p < database/design/seed.sql
-- Cau truyen: "Du lich Da Lat 2026" voi 3 nguoi dung + 1 khach khong tai khoan.
-- ============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------------------------------------------------------
-- users
-- ----------------------------------------------------------------------------
INSERT INTO users (user_id, full_name, email, password, avatar, provider, status) VALUES
(1, 'Alice Nguyen',  'alice@example.com',   '$2y$10$abcdefghijklmnopqrstuv', 'https://cdn.xyphora.com/avatars/1.png', 'email',  'active'),
(2, 'Bob Tran',      'bob@example.com',     '$2y$10$abcdefghijklmnopqrstuv', 'https://cdn.xyphora.com/avatars/2.png', 'email',  'active'),
(3, 'Charlie Le',    'charlie@example.com', '$2y$10$abcdefghijklmnopqrstuv', NULL,                                  'google', 'active'),
(4, 'Guest Account', 'guest@example.com',   NULL,                               NULL,                                  'email',  'inactive');

-- ----------------------------------------------------------------------------
-- events
-- ----------------------------------------------------------------------------
INSERT INTO events (event_id, owner_id, title, description, icon, cover_photo, currency, start_date, end_date, status) VALUES
(1, 1, 'Du lich Da Lat 2026', 'Tuan nghi he 4 ngay 3 dem tai Da Lat', 'mountain', 'https://cdn.xyphora.com/covers/1.jpg', 'VND', '2026-08-10', '2026-08-13', 'active'),
(2, 2, 'Tat nien cong ty', 'Tiec cuoi nam cua phong IT', 'party', NULL, 'VND', '2026-12-31', '2026-12-31', 'active');

-- ----------------------------------------------------------------------------
-- participants  (email bat buoc => UNIQUE(event_id, email) hop le)
-- ----------------------------------------------------------------------------
INSERT INTO participants (participant_id, event_id, user_id, display_name, email, avatar, role, joined_at, status) VALUES
(1, 1, 1, 'Alice Nguyen',  'alice@example.com',   'https://cdn.xyphora.com/avatars/1.png', 'owner',  '2026-08-01 09:00:00', 'active'),
(2, 1, 2, 'Bob Tran',      'bob@example.com',     'https://cdn.xyphora.com/avatars/2.png', 'admin',  '2026-08-02 10:30:00', 'active'),
(3, 1, 3, 'Charlie Le',    'charlie@example.com', NULL,                                     'member', '2026-08-03 14:00:00', 'active'),
(4, 1, NULL, 'Daisy Dang', 'daisy@example.com',   NULL,                                     'member', '2026-08-05 08:15:00', 'active'),
(5, 2, 2, 'Bob Tran',      'bob@example.com',     NULL,                                     'owner',  '2026-12-01 09:00:00', 'active'),
(6, 2, 1, 'Alice Nguyen',  'alice@example.com',   NULL,                                     'member', '2026-12-01 09:05:00', 'active');

-- ----------------------------------------------------------------------------
-- invitations
-- ----------------------------------------------------------------------------
INSERT INTO invitations (invitation_id, event_id, token, expired_at, used_at, status, created_at) VALUES
(1, 1, 'a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b', '2026-08-10 23:59:59', '2026-08-03 14:00:00', 'accepted', '2026-08-01 09:00:00'),
(2, 1, 'b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2', '2026-08-10 23:59:59', NULL,                 'pending',  '2026-08-05 08:00:00'),
(3, 1, 'c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3', '2026-07-30 23:59:59', NULL,                 'expired',  '2026-07-25 08:00:00');

-- ----------------------------------------------------------------------------
-- categories
-- ----------------------------------------------------------------------------
INSERT INTO categories (category_id, name, icon, color, type, is_default, created_by) VALUES
(1, 'An uong',        'restaurant', '#ef4444', 'expense', 1, NULL),
(2, 'Di chuyen',      'car',        '#3b82f6', 'expense', 1, NULL),
(3, 'Khach san',      'bed',        '#8b5cf6', 'expense', 1, NULL),
(4, 'Xang xe',        'fuel',       '#f59e0b', 'expense', 1, NULL),
(5, 'Giai tri',       'ticket',     '#10b981', 'expense', 1, NULL),
(6, 'Qua luu niem',   'gift',       '#ec4899', 'expense', 0, 1);

-- ----------------------------------------------------------------------------
-- photos
-- ----------------------------------------------------------------------------
INSERT INTO photos (photo_id, link, mime_type, size, uploaded_by, created_at) VALUES
(1, 'https://cdn.xyphora.com/receipts/hotel-dalat.jpg', 'image/jpeg', 1523456, 1, '2026-08-10 20:00:00'),
(2, 'https://cdn.xyphora.com/receipts/gas-station.png', 'image/png',   845231, 2, '2026-08-10 18:30:00');

-- ----------------------------------------------------------------------------
-- expenses
-- ----------------------------------------------------------------------------
INSERT INTO expenses (expense_id, event_id, created_by, payer_id, category_id, title, description,
                      amount, currency, expense_date, expense_type, split_method, note, is_deleted) VALUES
(1, 1, 1, 1, 3, 'Khach san Da Lat', '2 phong x 2 dem', 1200000.00, 'VND', '2026-08-10', 'expense', 'equal', 'Dat qua Booking', 0),
(2, 1, 2, 2, 4, 'Do xang doc duong', 'TP.HCM - Da Lat',  600000.00, 'VND', '2026-08-10', 'expense', 'equal', NULL, 0),
(3, 1, 1, 1, 1, 'An toi - Lau de', 'Nha hang Lau De My Khanh', 800000.00, 'VND', '2026-08-11', 'expense', 'exact', 'Chia theo mon da goi', 0),
(4, 1, 3, 3, 2, 'Taxi san bay', 'Xe 4 cho tu Da Lat ra san bay', 240000.00, 'VND', '2026-08-10', 'expense', 'percentage', NULL, 0),
(5, 1, 4, 4, 2, 'Thue xe may 3 ngay', 'Honda Vision x 2', 500000.00, 'VND', '2026-08-10', 'expense', 'share', 'Alice di 2 xe', 0),
(6, 1, 3, 3, 5, 'Mua banh keo', NULL, 150000.00, 'VND', '2026-08-11', 'expense', 'equal', NULL, 1);

-- ----------------------------------------------------------------------------
-- expense_splits  (khoa chinh tong hop: expense_id + participant_id)
-- ----------------------------------------------------------------------------
-- Expense 1: equal 1.200.000 / 4 = 300.000
INSERT INTO expense_splits (expense_id, participant_id, amount, percentage, share, status) VALUES
(1, 1, 300000.00, NULL, NULL, 'pending'),
(1, 2, 300000.00, NULL, NULL, 'settled'),
(1, 3, 300000.00, NULL, NULL, 'pending'),
(1, 4, 300000.00, NULL, NULL, 'pending');
-- Expense 2: equal 600.000 / 3 = 200.000 (khong tinh Daisy)
INSERT INTO expense_splits (expense_id, participant_id, amount, percentage, share, status) VALUES
(2, 1, 200000.00, NULL, NULL, 'pending'),
(2, 2, 200000.00, NULL, NULL, 'pending'),
(2, 3, 200000.00, NULL, NULL, 'pending');
-- Expense 3: exact - Alice 200.000, Bob 300.000, Charlie 300.000
INSERT INTO expense_splits (expense_id, participant_id, amount, percentage, share, status) VALUES
(3, 1, 200000.00, NULL, NULL, 'pending'),
(3, 2, 300000.00, NULL, NULL, 'settled'),
(3, 3, 300000.00, NULL, NULL, 'pending');
-- Expense 4: percentage - Alice 50%, Bob 30%, Charlie 20%
INSERT INTO expense_splits (expense_id, participant_id, amount, percentage, share, status) VALUES
(4, 1, 120000.00, 50.00, NULL, 'pending'),
(4, 2,  72000.00, 30.00, NULL, 'pending'),
(4, 3,  48000.00, 20.00, NULL, 'pending');
-- Expense 5: share - tong 5 phan, moi phan 100.000
INSERT INTO expense_splits (expense_id, participant_id, amount, percentage, share, status) VALUES
(5, 1, 200000.00, NULL, 2, 'pending'),
(5, 2, 100000.00, NULL, 1, 'pending'),
(5, 3, 100000.00, NULL, 1, 'pending'),
(5, 4, 100000.00, NULL, 1, 'pending');

-- ----------------------------------------------------------------------------
-- expense_photos
-- ----------------------------------------------------------------------------
INSERT INTO expense_photos (expense_id, photo_id) VALUES
(1, 1),
(2, 2);

-- ----------------------------------------------------------------------------
-- expense_history
-- ----------------------------------------------------------------------------
INSERT INTO expense_history (history_id, expense_id, updated_by, field_name, old_value, new_value, updated_at) VALUES
(1, 3, 1, 'amount',       '850000.00',       '800000.00',       '2026-08-11 21:00:00'),
(2, 3, 1, 'title',        'An toi - Lau de', 'An toi - Lau De', '2026-08-11 21:05:00'),
(3, 5, 4, 'amount',       '550000.00',       '500000.00',       '2026-08-10 19:00:00');

-- ----------------------------------------------------------------------------
-- settlements  (Bob tra Alice 600.000 da xong; Charlie & Alice con no)
-- ----------------------------------------------------------------------------
INSERT INTO settlements (settlement_id, event_id, from_participant, to_participant, amount, status, note, settled_at, created_at) VALUES
(1, 1, 2, 1, 600000.00, 'completed', 'Chuyen khoan MB Bank', '2026-08-12 20:00:00', '2026-08-12 19:30:00'),
(2, 1, 3, 1, 600000.00, 'pending',   NULL,                    NULL,                   '2026-08-13 10:00:00'),
(3, 1, 1, 4, 100000.00, 'pending',   'Phan cong no thue xe',  NULL,                   '2026-08-13 10:30:00');

-- ----------------------------------------------------------------------------
-- notifications
-- ----------------------------------------------------------------------------
INSERT INTO notifications (notification_id, user_id, type, title, content, reference_id, is_read, created_at) VALUES
(1, 2, 'invitation',            'Ban duoc moi vao nhom',     'Alice da moi ban tham gia nhom "Du lich Da Lat 2026"', 1, 0, '2026-08-01 09:00:00'),
(2, 1, 'expense_added',         'Chi phi moi',               'Bob da them "Do xang doc duong" - 600.000 VND',        2, 0, '2026-08-10 18:30:00'),
(3, 2, 'settlement_completed',  'Da thanh toan',             'Ban da thanh toan 600.000 VND cho Alice',              1, 1, '2026-08-12 20:00:00'),
(4, 3, 'settlement_request',    'Can thanh toan cong no',    'Alice de nghi ban thanh toan 600.000 VND',             2, 0, '2026-08-13 10:00:00');

-- ----------------------------------------------------------------------------
-- refresh_tokens
-- ----------------------------------------------------------------------------
INSERT INTO refresh_tokens (token_id, user_id, token, expired_at, created_at) VALUES
(1, 1, 'def50200a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8', '2026-08-16 10:00:00', '2026-08-06 10:00:00'),
(2, 2, 'def50200b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8', '2026-08-16 11:00:00', '2026-08-06 11:00:00');

SET FOREIGN_KEY_CHECKS = 1;
