namespace :db do
  desc '本番環境のデータベースを安全にリセット（外部キー制約を考慮）'
  task reset_production_data: :environment do
    if Rails.env.production?
      puts '⚠️  本番環境のデータベースリセットを開始します...'
      puts '⚠️  この操作は元に戻せません。続行しますか？'
      puts '⚠️  5秒後に自動的に開始されます...'
      sleep(5)

      ActiveRecord::Base.transaction do
        puts "\n1. 購入者住所（addresses）を削除中..."
        deleted_addresses = Address.delete_all
        puts "   ✓ #{deleted_addresses}件の住所を削除しました"

        puts "\n2. 購入情報（orders）を削除中..."
        deleted_orders = Order.delete_all
        puts "   ✓ #{deleted_orders}件の購入情報を削除しました"

        puts "\n3. 出品情報（items）と画像を削除中..."
        deleted_items = 0
        Item.find_each do |item|
          item.image.purge if item.image.attached?
          item.destroy
          deleted_items += 1
        end
        puts "   ✓ #{deleted_items}件の出品情報を削除しました"

        puts "\n4. Active Storageのデータを削除中..."
        deleted_attachments = ActiveStorage::Attachment.delete_all
        deleted_blobs = ActiveStorage::Blob.delete_all
        puts "   ✓ #{deleted_attachments}件の添付ファイルと#{deleted_blobs}件のBlobを削除しました"

        puts "\n5. ユーザー情報（users）を削除中..."
        deleted_users = User.delete_all
        puts "   ✓ #{deleted_users}件のユーザー情報を削除しました"

        puts "\n✅ データベースのリセットが完了しました！"
        puts "\n現在のデータ件数:"
        puts "   Addresses: #{Address.count}"
        puts "   Orders: #{Order.count}"
        puts "   Items: #{Item.count}"
        puts "   Users: #{User.count}"
        puts "   ActiveStorage::Attachments: #{ActiveStorage::Attachment.count}"
        puts "   ActiveStorage::Blobs: #{ActiveStorage::Blob.count}"
      rescue StandardError => e
        puts "\n❌ エラーが発生しました: #{e.message}"
        puts e.backtrace.first(5)
        raise ActiveRecord::Rollback
      end
    else
      puts '❌ このタスクは本番環境でのみ実行できます。'
      puts "   現在の環境: #{Rails.env}"
    end
  end
end

