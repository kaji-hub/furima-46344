class OrderAddress
  include ActiveModel::Model
  attr_accessor :item_id, :user_id, :token, :postal_code, :prefecture_id, :city, :house_number, :building_name, :phone_number

  with_options presence: true do
    validates :item_id
    validates :user_id
    validates :token
    validates :postal_code, format: { with: /\A\d{3}-\d{4}\z/, message: 'は半角「3桁-4桁」形式で入力してください' }
    validates :prefecture_id, numericality: { other_than: 1, message: "can't be blank" }
    validates :city
    validates :house_number
    validates :phone_number, format: { with: /\A\d{10,11}\z/, message: 'は半角数字10〜11桁で入力してください' }
  end

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      order = Order.create!(item_id: item_id, user_id: user_id)
      Address.create!(
        order_id: order.id,
        postal_code: postal_code,
        prefecture_id: prefecture_id,
        city: city,
        house_number: house_number,
        building_name: building_name,
        phone_number: phone_number
      )
    end
    true
  rescue ActiveRecord::RecordInvalid
    false
  end
end

