-- 本番環境のデータベースリセット用SQLスクリプト
-- Renderのデータベースに接続して実行してください
-- 外部キー制約を考慮した順序で削除します

-- ⚠️ 警告: この操作は元に戻せません。実行前に必ずバックアップを取得してください。

-- 方法1: 外部キー制約を一時的に無効化して削除（推奨）
BEGIN;

-- 外部キー制約を一時的に無効化
SET session_replication_role = 'replica';

-- 1. 購入者住所（addresses）を削除
DELETE FROM addresses;

-- 2. 購入情報（orders）を削除
DELETE FROM orders;

-- 3. Active Storageの添付ファイルを削除
DELETE FROM active_storage_attachments;

-- 4. Active StorageのBlobを削除
DELETE FROM active_storage_blobs;

-- 5. 出品情報（items）を削除
DELETE FROM items;

-- 6. ユーザー情報（users）を削除
DELETE FROM users;

-- 外部キー制約を再有効化
SET session_replication_role = 'origin';

COMMIT;

-- 方法2: もし方法1が動作しない場合、以下のCASCADE削除を使用してください
-- BEGIN;
-- DELETE FROM addresses CASCADE;
-- DELETE FROM orders CASCADE;
-- DELETE FROM active_storage_attachments CASCADE;
-- DELETE FROM active_storage_blobs CASCADE;
-- DELETE FROM items CASCADE;
-- DELETE FROM users CASCADE;
-- COMMIT;

-- 確認用クエリ（削除後に実行して確認）
-- SELECT 'Addresses' as table_name, COUNT(*) as count FROM addresses
-- UNION ALL
-- SELECT 'Orders', COUNT(*) FROM orders
-- UNION ALL
-- SELECT 'Items', COUNT(*) FROM items
-- UNION ALL
-- SELECT 'Users', COUNT(*) FROM users
-- UNION ALL
-- SELECT 'ActiveStorage::Attachments', COUNT(*) FROM active_storage_attachments
-- UNION ALL
-- SELECT 'ActiveStorage::Blobs', COUNT(*) FROM active_storage_blobs;

