require 'rails_helper'

RSpec.describe Item, type: :model do
  before do
    @user = create(:user)
  end

  describe '商品名のバリデーション' do
    context '正常系（登録できるとき）' do
      it '40文字の場合は有効' do
        item = build(:item, name: 'a' * 40, user: @user)
        expect(item).to be_valid
      end
    end

    context '異常系（登録できないとき）' do
      it '空の場合は無効' do
        item = build(:item, name: nil, user: @user)
        item.valid?
        expect(item.errors[:name]).to include("can't be blank")
      end

      it '41文字以上の場合は無効' do
        item = build(:item, name: 'a' * 41, user: @user)
        item.valid?
        expect(item.errors[:name]).to include('is too long (maximum is 40 characters)')
      end
    end
  end

  describe '商品の説明のバリデーション' do
    context '正常系（登録できるとき）' do
      it '1000文字の場合は有効' do
        item = build(:item, description: 'a' * 1000, user: @user)
        expect(item).to be_valid
      end
    end

    context '異常系（登録できないとき）' do
      it '空の場合は無効' do
        item = build(:item, description: nil, user: @user)
        item.valid?
        expect(item.errors[:description]).to include("can't be blank")
      end

      it '1001文字以上の場合は無効' do
        item = build(:item, description: 'a' * 1001, user: @user)
        item.valid?
        expect(item.errors[:description]).to include('is too long (maximum is 1000 characters)')
      end
    end
  end

  describe '価格のバリデーション' do
    context '正常系（登録できるとき）' do
      it '300円の場合は有効' do
        item = build(:item, price: 300, user: @user)
        expect(item).to be_valid
      end

      it '9999999円の場合は有効' do
        item = build(:item, price: 9_999_999, user: @user)
        expect(item).to be_valid
      end

      it '整数の場合は有効' do
        item = build(:item, price: 1000, user: @user)
        expect(item).to be_valid
      end
    end

    context '異常系（登録できないとき）' do
      it '空の場合は無効' do
        item = build(:item, price: nil, user: @user)
        item.valid?
        expect(item.errors[:price]).to include("can't be blank")
      end

      it '299円以下の場合は無効' do
        item = build(:item, price: 299, user: @user)
        item.valid?
        expect(item.errors[:price]).to include('must be greater than or equal to 300')
      end

      it '10000000円以上の場合は無効' do
        item = build(:item, price: 10_000_000, user: @user)
        item.valid?
        expect(item.errors[:price]).to include('must be less than or equal to 9999999')
      end

      it '小数の場合は無効' do
        item = build(:item, price: 1000.5, user: @user)
        item.valid?
        expect(item.errors[:price]).to include('must be an integer')
      end
    end
  end

  describe 'カテゴリーのバリデーション' do
    context '正常系（登録できるとき）' do
      it 'カテゴリーが選択されている場合は有効' do
        item = build(:item, category_id: 2, user: @user)
        expect(item).to be_valid
      end
    end

    context '異常系（登録できないとき）' do
      it '---（id: 1）が選択されている場合は無効' do
        item = build(:item, category_id: 1, user: @user)
        item.valid?
        expect(item.errors[:category_id]).to include("can't be blank")
      end
    end
  end

  describe '商品の状態のバリデーション' do
    context '正常系（登録できるとき）' do
      it '商品の状態が選択されている場合は有効' do
        item = build(:item, condition_id: 2, user: @user)
        expect(item).to be_valid
      end
    end

    context '異常系（登録できないとき）' do
      it '---（id: 1）が選択されている場合は無効' do
        item = build(:item, condition_id: 1, user: @user)
        item.valid?
        expect(item.errors[:condition_id]).to include("can't be blank")
      end
    end
  end

  describe '配送料の負担のバリデーション' do
    context '正常系（登録できるとき）' do
      it '配送料の負担が選択されている場合は有効' do
        item = build(:item, shipping_fee_id: 2, user: @user)
        expect(item).to be_valid
      end
    end

    context '異常系（登録できないとき）' do
      it '---（id: 1）が選択されている場合は無効' do
        item = build(:item, shipping_fee_id: 1, user: @user)
        item.valid?
        expect(item.errors[:shipping_fee_id]).to include("can't be blank")
      end
    end
  end

  describe '発送元の地域のバリデーション' do
    context '正常系（登録できるとき）' do
      it '発送元の地域が選択されている場合は有効' do
        item = build(:item, prefecture_id: 2, user: @user)
        expect(item).to be_valid
      end
    end

    context '異常系（登録できないとき）' do
      it '---（id: 1）が選択されている場合は無効' do
        item = build(:item, prefecture_id: 1, user: @user)
        item.valid?
        expect(item.errors[:prefecture_id]).to include("can't be blank")
      end
    end
  end

  describe '発送までの日数のバリデーション' do
    context '正常系（登録できるとき）' do
      it '発送までの日数が選択されている場合は有効' do
        item = build(:item, scheduled_delivery_id: 2, user: @user)
        expect(item).to be_valid
      end
    end

    context '異常系（登録できないとき）' do
      it '---（id: 1）が選択されている場合は無効' do
        item = build(:item, scheduled_delivery_id: 1, user: @user)
        item.valid?
        expect(item.errors[:scheduled_delivery_id]).to include("can't be blank")
      end
    end
  end

  describe '画像のバリデーション' do
    context '正常系（登録できるとき）' do
      it '画像が添付されている場合は有効' do
        item = build(:item, user: @user)
        expect(item).to be_valid
      end
    end

    context '異常系（登録できないとき）' do
      it '画像が添付されていない場合は無効' do
        item = build(:item, user: @user)
        item.image.detach
        item.valid?
        expect(item.errors[:image]).to include("can't be blank")
      end
    end
  end
end
