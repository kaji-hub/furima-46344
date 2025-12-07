require 'rails_helper'

RSpec.describe OrderAddress, type: :model do
  before do
    @user = create(:user)
    @item = create(:item, user: @user)
    @order_address = build(:order_address, item_id: @item.id, user_id: @user.id)
  end

  describe '購入情報のバリデーションテスト' do
    context '正常系' do
      it 'すべて正しく入力されていれば保存できること' do
        expect(@order_address).to be_valid
        expect { @order_address.save }.to change { Order.count }.by(1).and change { Address.count }.by(1)

        order = Order.last
        address = Address.last
        expect(order.item_id).to eq(@item.id)
        expect(order.user_id).to eq(@user.id)
        expect(address.postal_code).to eq('123-4567')
        expect(address.prefecture_id).to eq(2)
        expect(address.city).to eq('横浜市緑区')
        expect(address.house_number).to eq('青山1-1-1')
        expect(address.building_name).to eq('柳ビル103')
        expect(address.phone_number).to eq('09012345678')
      end
      it '建物名が空でも保存できること' do
        @order_address.building_name = ''
        expect(@order_address).to be_valid
        expect { @order_address.save }.to change { Order.count }.by(1).and change { Address.count }.by(1)

        address = Address.last
        expect(address.building_name).to eq('')
      end
    end

    context '異常系' do
      it 'postal_codeが空の場合は無効' do
        @order_address.postal_code = nil
        @order_address.valid?
        expect(@order_address.errors[:postal_code]).to include("can't be blank")
      end

      it 'postal_codeがハイフンなし（1234567）の場合は無効' do
        @order_address.postal_code = '1234567'
        @order_address.valid?
        expect(@order_address.errors[:postal_code]).to include('は半角「3桁-4桁」形式で入力してください')
      end

      it 'postal_codeが全角の場合は無効' do
        @order_address.postal_code = '１２３-４５６７'
        @order_address.valid?
        expect(@order_address.errors[:postal_code]).to include('は半角「3桁-4桁」形式で入力してください')
      end

      it 'postal_codeが不正形式（12-345）の場合は無効' do
        @order_address.postal_code = '12-345'
        @order_address.valid?
        expect(@order_address.errors[:postal_code]).to include('は半角「3桁-4桁」形式で入力してください')
      end

      it 'prefecture_idが1（未選択）の場合は無効' do
        @order_address.prefecture_id = 1
        @order_address.valid?
        expect(@order_address.errors[:prefecture_id]).to include("can't be blank")
      end

      it 'cityが空の場合は無効' do
        @order_address.city = nil
        @order_address.valid?
        expect(@order_address.errors[:city]).to include("can't be blank")
      end

      it 'house_numberが空の場合は無効' do
        @order_address.house_number = nil
        @order_address.valid?
        expect(@order_address.errors[:house_number]).to include("can't be blank")
      end

      it 'phone_numberが空の場合は無効' do
        @order_address.phone_number = nil
        @order_address.valid?
        expect(@order_address.errors[:phone_number]).to include("can't be blank")
      end

      it 'phone_numberが9桁以下の場合は無効' do
        @order_address.phone_number = '090123456'
        @order_address.valid?
        expect(@order_address.errors[:phone_number]).to include('は半角数字10〜11桁で入力してください')
      end

      it 'phone_numberが12桁以上の場合は無効' do
        @order_address.phone_number = '090123456789'
        @order_address.valid?
        expect(@order_address.errors[:phone_number]).to include('は半角数字10〜11桁で入力してください')
      end

      it 'phone_numberがハイフン含む場合は無効' do
        @order_address.phone_number = '090-1234-5678'
        @order_address.valid?
        expect(@order_address.errors[:phone_number]).to include('は半角数字10〜11桁で入力してください')
      end

      it 'phone_numberが全角の場合は無効' do
        @order_address.phone_number = '０９０１２３４５６７８'
        @order_address.valid?
        expect(@order_address.errors[:phone_number]).to include('は半角数字10〜11桁で入力してください')
      end

      it 'tokenが空の場合は無効' do
        @order_address.token = nil
        @order_address.valid?
        expect(@order_address.errors[:token]).to include("can't be blank")
      end

      it 'item_idが空の場合は無効' do
        @order_address.item_id = nil
        @order_address.valid?
        expect(@order_address.errors[:item_id]).to include("can't be blank")
      end

      it 'user_idが空の場合は無効' do
        @order_address.user_id = nil
        @order_address.valid?
        expect(@order_address.errors[:user_id]).to include("can't be blank")
      end
    end
  end
end
