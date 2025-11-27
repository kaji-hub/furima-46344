class UpdateCategoryIdsForMenAndLadies < ActiveRecord::Migration[7.1]
  def up
    # 以前の設定: id: 2 = レディース、id: 3 = メンズ
    # 新しい設定: id: 2 = メンズ、id: 3 = レディース
    # 
    # 移行ロジック:
    # 1. category_id = 2 (旧レディース) を一時的に 99 に変更
    # 2. category_id = 3 (旧メンズ) を 2 (新メンズ) に変更
    # 3. category_id = 99 (旧レディース) を 3 (新レディース) に変更
    
    # 一時的な値に変更
    Item.where(category_id: 2).update_all(category_id: 99)
    
    # 旧メンズを新メンズに変更
    Item.where(category_id: 3).update_all(category_id: 2)
    
    # 旧レディースを新レディースに変更
    Item.where(category_id: 99).update_all(category_id: 3)
  end

  def down
    # ロールバック時の処理（逆の操作）
    # 1. category_id = 3 (新レディース) を一時的に 99 に変更
    # 2. category_id = 2 (新メンズ) を 3 (旧メンズ) に変更
    # 3. category_id = 99 (新レディース) を 2 (旧レディース) に変更
    
    Item.where(category_id: 3).update_all(category_id: 99)
    Item.where(category_id: 2).update_all(category_id: 3)
    Item.where(category_id: 99).update_all(category_id: 2)
  end
end
