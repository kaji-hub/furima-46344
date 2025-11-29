require 'rails_helper'

RSpec.describe Item, type: :model do
  before do
    @user = create(:user)
  end

  describe '商品出品時のバリデーションテスト' do
    before do
      @item = build(:item, user: @user)
    end

    context '正常系' do
      it 'すべて正しく入力されていれば出品できる' do
        expect(@item).to be_valid
      end
    end

    context '異常系' do
      it '商品名が空の場合は無効' do
        @item.name = nil
        @item.valid?
        expect(@item.errors[:name]).to include("can't be blank")
      end

      it '商品名が41文字以上の場合は無効' do
        @item.name = 'a' * 41
        @item.valid?
        expect(@item.errors[:name]).to include('is too long (maximum is 40 characters)')
      end

      it '商品の説明が空の場合は無効' do
        @item.description = nil
        @item.valid?
        expect(@item.errors[:description]).to include("can't be blank")
      end

      it '商品の説明が1001文字以上の場合は無効' do
        @item.description = 'a' * 1001
        @item.valid?
        expect(@item.errors[:description]).to include('is too long (maximum is 1000 characters)')
      end

      it '価格が空の場合は無効' do
        @item.price = nil
        @item.valid?
        expect(@item.errors[:price]).to include("can't be blank")
      end

      it '価格が299円以下の場合は無効' do
        @item.price = 299
        @item.valid?
        expect(@item.errors[:price]).to include('must be greater than or equal to 300')
      end

      it '価格が10000000円以上の場合は無効' do
        @item.price = 10_000_000
        @item.valid?
        expect(@item.errors[:price]).to include('must be less than or equal to 9999999')
      end

      it '価格が小数の場合は無効' do
        @item.price = 1000.5
        @item.valid?
        expect(@item.errors[:price]).to include('must be an integer')
      end

      it '価格が全角数字の場合は無効' do
        @item.price = '１０００'
        @item.valid?
        expect(@item.errors[:price]).to include('is not a number')
      end

      it '価格が文字列の場合は無効' do
        @item.price = 'abc'
        @item.valid?
        expect(@item.errors[:price]).to include('is not a number')
      end

      it 'カテゴリーが---（id: 1）が選択されている場合は無効' do
        @item.category_id = 1
        @item.valid?
        expect(@item.errors[:category_id]).to include("can't be blank")
      end

      it '商品の状態が---（id: 1）が選択されている場合は無効' do
        @item.condition_id = 1
        @item.valid?
        expect(@item.errors[:condition_id]).to include("can't be blank")
      end

      it '配送料の負担が---（id: 1）が選択されている場合は無効' do
        @item.shipping_fee_id = 1
        @item.valid?
        expect(@item.errors[:shipping_fee_id]).to include("can't be blank")
      end

      it '発送元の地域が---（id: 1）が選択されている場合は無効' do
        @item.prefecture_id = 1
        @item.valid?
        expect(@item.errors[:prefecture_id]).to include("can't be blank")
      end

      it '発送までの日数が---（id: 1）が選択されている場合は無効' do
        @item.scheduled_delivery_id = 1
        @item.valid?
        expect(@item.errors[:scheduled_delivery_id]).to include("can't be blank")
      end

      it '画像が添付されていない場合は無効' do
        @item.image.detach
        @item.valid?
        expect(@item.errors[:image]).to include("can't be blank")
      end

      it 'userが紐づいていない場合は無効' do
        @item.user = nil
        @item.valid?
        expect(@item.errors[:user]).to include('must exist')
      end
    end
  end
end
