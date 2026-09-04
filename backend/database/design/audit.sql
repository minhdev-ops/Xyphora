-- ============================================================================
-- Xyphora - Script KIEM TRA TINH TOAN VEN DU LIEU (chay lai bat ky luc nao)
-- Chay: mysql -u root -p xyphora < database/design/audit.sql
-- Moi query in ra dong 'OK' hoac liet ke loi can xu ly.
-- ============================================================================

-- 1. Tat ca bang phai la InnoDB + utf8mb4 (MyISAM = loi FK 1824 tuong lai)
SELECT TABLE_NAME, ENGINE, TABLE_COLLATION AS bad
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE()
  AND (ENGINE <> 'InnoDB' OR TABLE_COLLATION NOT LIKE 'utf8mb4%')
  AND TABLE_NAME NOT LIKE 'z_%';

-- 2. Bang nao CON THIEU FOREIGN KEY (co FK den bang khac nhung khong khai)
SELECT TABLE_NAME, COLUMN_NAME
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND COLUMN_NAME IN ('event_id', 'owner_id', 'user_id', 'created_by', 'payer_id',
                      'category_id', 'uploaded_by', 'expense_id', 'photo_id',
                      'participant_id', 'updated_by', 'from_participant',
                      'to_participant')
  AND COLUMN_NAME <> 'event_id' -- events.event_id la PK
  AND TABLE_NAME NOT IN ('expenses') -- kiem tra rieng duoi
  AND NOT EXISTS (
      SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k
      WHERE k.TABLE_SCHEMA = DATABASE()
        AND k.TABLE_NAME = information_schema.COLUMNS.TABLE_NAME
        AND k.COLUMN_NAME = information_schema.COLUMNS.COLUMN_NAME
        AND k.REFERENCED_TABLE_NAME IS NOT NULL
  );

-- 3. Orphan: ban ghi con tro toi ban ghi cha KHONG TON TAI (FK loi khong catch duoc)
SELECT 'expenses->events' AS check_name,
       COUNT(*) AS orphans FROM expenses e
  LEFT JOIN events ev ON ev.event_id = e.event_id WHERE ev.event_id IS NULL
UNION ALL
SELECT 'expenses->participants(payer)', COUNT(*) FROM expenses x
  LEFT JOIN participants p ON p.participant_id = x.payer_id
  WHERE p.participant_id IS NULL OR p.event_id <> x.event_id
UNION ALL
SELECT 'expense_splits->expenses', COUNT(*) FROM expense_splits s
  LEFT JOIN expenses e ON e.expense_id = s.expense_id WHERE e.expense_id IS NULL
UNION ALL
SELECT 'expense_splits->participants', COUNT(*) FROM expense_splits s
  LEFT JOIN participants p ON p.participant_id = s.participant_id
  WHERE p.participant_id IS NULL OR p.status = 'removed'
UNION ALL
SELECT 'settlements->events', COUNT(*) FROM settlements s
  LEFT JOIN events e ON e.event_id = s.event_id WHERE e.event_id IS NULL
UNION ALL
SELECT 'settlements->from(cross-event)', COUNT(*) FROM settlements s
  LEFT JOIN participants p ON p.participant_id = s.from_participant
  WHERE p.participant_id IS NULL OR p.event_id <> s.event_id
UNION ALL
SELECT 'settlements->to(cross-event)', COUNT(*) FROM settlements s
  LEFT JOIN participants p ON p.participant_id = s.to_participant
  WHERE p.participant_id IS NULL OR p.event_id <> s.event_id
UNION ALL
SELECT 'participants->users', COUNT(*) FROM participants p
  LEFT JOIN users u ON u.id = p.user_id
  WHERE p.user_id IS NOT NULL AND u.id IS NULL;

-- 4. Bat bien nghiep vu:
--    a) Tong splits phai bang amount cua expense
SELECT e.expense_id, e.amount, SUM(s.amount) AS split_total
FROM expenses e LEFT JOIN expense_splits s USING (expense_id)
WHERE e.is_deleted = 0
GROUP BY e.expense_id, e.amount
HAVING split_total <> e.amount OR split_total IS NULL;

--    b) Loi moi 'accepted' phai co used_at (CHECK da chan, kiem tra du phong)
SELECT * FROM invitations WHERE (status = 'accepted') != (used_at IS NOT NULL);

--    c) Settlement 'completed' phai co settled_at
SELECT * FROM settlements WHERE (status = 'completed') != (settled_at IS NOT NULL);

--    d) Mot event chi duoc phep 1 owner (uq_participants_single_owner)
SELECT event_id, COUNT(*) AS owners
FROM participants WHERE role = 'owner'
GROUP BY event_id HAVING COUNT(*) > 1;

--    e) Duplicate email trong cung event
SELECT event_id, email, COUNT(*) AS dup
FROM participants
GROUP BY event_id, email HAVING COUNT(*) > 1;

-- 5. Tong hop danh sach FK hien co
SELECT TABLE_NAME, CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE() AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- 6. Tong hop danh sach CHECK
SELECT tc.TABLE_NAME, cc.CONSTRAINT_NAME
FROM information_schema.TABLE_CONSTRAINTS tc
JOIN information_schema.CHECK_CONSTRAINTS cc
  ON cc.CONSTRAINT_SCHEMA = tc.CONSTRAINT_SCHEMA
 AND cc.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
WHERE tc.CONSTRAINT_SCHEMA = DATABASE() AND tc.CONSTRAINT_TYPE = 'CHECK'
ORDER BY tc.TABLE_NAME;

-- 7. AUTO_INCREMENT kiem tra (khong duoc nho hon MAX(id))
SELECT TABLE_NAME, AUTO_INCREMENT
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
