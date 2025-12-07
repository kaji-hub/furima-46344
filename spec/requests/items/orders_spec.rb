require 'rails_helper'

RSpec.describe 'Items::Orders', type: :request do
  before do
    @user = create(:user)
    @other_user = create(:user)
    @item = create(:item, user: @user)
  end

  describe 'GET #new' do
    context '正常系' do
      it 'ログイン状態で、自身が出品していない販売中商品の購入ページにアクセスできること' do
        sign_in @other_user
        get new_item_order_path(@item)
        expect(response).to have_http_status(:success)
      end
    end

    context '異常系' do
      it '出品者が購入ページへアクセスするとトップへリダイレクトされること' do
        sign_in @user
        get new_item_order_path(@item)
        expect(response).to redirect_to(root_path)
      end

      it '売却済み商品の購入ページアクセスするとトップへリダイレクトされること' do
        sold_item = create(:item, user: @user)
        create(:order, item: sold_item, user: @other_user)
        sign_in @other_user
        get new_item_order_path(sold_item)
        expect(response).to redirect_to(root_path)
      end

      it '未ログインで購入ページアクセスするとログインページへリダイレクトされること' do
        get new_item_order_path(@item)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST #create' do
    before do
      @order_address_params = {
        order_address: {
          postal_code: '123-4567',
          prefecture_id: 2,
          city: '横浜市緑区',
          house_number: '青山1-1-1',
          building_name: '柳ビル103',
          phone_number: '09012345678',
          token: 'tok_test_1234567890abcdef'
        }
      }
    end

    context '正常系' do
      it 'すべて正しく入力されていれば購入でき、トップページへ遷移すること' do
        sign_in @other_user
        allow(Payjp::Charge).to receive(:create).and_return(double(id: 'ch_test_1234567890abcdef'))
        expect do
          post item_orders_path(@item), params: @order_address_params
        end.to change { Order.count }.by(1).and change { Address.count }.by(1)
        expect(response).to redirect_to(root_path)
      end
    end

    context '異常系' do
      it '出品者が購入しようとするとトップへリダイレクトされること' do
        sign_in @user
        post item_orders_path(@item), params: @order_address_params
        expect(response).to redirect_to(root_path)
      end

      it '売却済み商品を購入しようとするとトップへリダイレクトされること' do
        sold_item = create(:item, user: @user)
        create(:order, item: sold_item, user: @other_user)
        sign_in @other_user
        post item_orders_path(sold_item), params: @order_address_params
        expect(response).to redirect_to(root_path)
      end

      it '未ログインで購入しようとするとログインページへリダイレクトされること' do
        post item_orders_path(@item), params: @order_address_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
