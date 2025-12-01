FactoryBot.define do
  factory :item do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    price { Faker::Number.between(from: 300, to: 9_999_999) }
    category_id { 2 }
    condition_id { 2 }
    shipping_fee_id { 2 }
    prefecture_id { 2 }
    scheduled_delivery_id { 2 }
    association :user

    after(:build) do |item|
      # テスト用の画像ファイルを添付
      image_path = Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')
      if File.exist?(image_path)
        item.image.attach(io: File.open(image_path), filename: 'test_image.png', content_type: 'image/png')
      else
        # 画像ファイルが存在しない場合は、空のファイルを作成して添付
        FileUtils.mkdir_p(File.dirname(image_path))
        File.write(image_path, 'test image data')
        item.image.attach(io: File.open(image_path), filename: 'test_image.png', content_type: 'image/png')
      end
    end
  end
end
