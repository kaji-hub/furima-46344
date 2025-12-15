class OrderAddress
  include ActiveModel::Model
  attr_accessor :item_id, :user_id, :token, :postal_code, :prefecture_id, :city, :house_number, :building_name, :phone_number

  with_options presence: true do
    validates :item_id
    validates :user_id
    validates :token
    validates :postal_code, format: { with: /\A\d{3}-\d{4}\z/, message: 'is invalid. Enter it as follows (e.g. 123-4567)' }
    validates :prefecture_id, numericality: { other_than: 1, message: "can't be blank" }
    validates :city
    validates :house_number
  end

  validates :phone_number, presence: true
  validates :phone_number,
            length: { minimum: 10, maximum: 11, too_short: 'is too short', too_long: 'is invalid. Input only number' }
  validates :phone_number, format: { with: /\A\d+\z/, message: 'is invalid. Input only number' }

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
