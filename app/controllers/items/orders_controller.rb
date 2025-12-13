class Items::OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item
  before_action :ensure_not_owner
  before_action :ensure_not_sold

  def new
    @order_address = OrderAddress.new
    # 環境変数が設定されていない場合のエラーハンドリング
    payjp_public_key = ENV['PAYJP_PUBLIC_KEY']
    if payjp_public_key.blank?
      Rails.logger.error "PAYJP_PUBLIC_KEY環境変数が設定されていません"
      flash[:alert] = "決済機能の設定が正しくありません。管理者にお問い合わせください。"
    end
    gon.public_key = payjp_public_key
  end

  def create
    @order_address = OrderAddress.new(order_address_params)
    # 環境変数が設定されていない場合のエラーハンドリング
    payjp_public_key = ENV['PAYJP_PUBLIC_KEY']
    if payjp_public_key.blank?
      Rails.logger.error "PAYJP_PUBLIC_KEY環境変数が設定されていません"
      flash[:alert] = "決済機能の設定が正しくありません。管理者にお問い合わせください。"
    end
    gon.public_key = payjp_public_key

    if @order_address.save
      pay_item
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_item
    @item = Item.find(params[:item_id])
  end

  def ensure_not_owner
    redirect_to root_path if @item.user_id == current_user.id
  end

  def ensure_not_sold
    redirect_to root_path if @item.order.present?
  end

  def order_address_params
    params.require(:order_address).permit(:postal_code, :prefecture_id, :city, :house_number, :building_name, :phone_number, :token).merge(
      item_id: params[:item_id], user_id: current_user.id
    )
  end

  def pay_item
    payjp_secret_key = ENV['PAYJP_SECRET_KEY']
    if payjp_secret_key.blank?
      Rails.logger.error "PAYJP_SECRET_KEY環境変数が設定されていません"
      raise "決済処理の設定が正しくありません"
    end
    
    Payjp.api_key = payjp_secret_key
    Payjp::Charge.create(
      amount: @item.price,
      card: @order_address.token,
      currency: 'jpy'
    )
  rescue Payjp::CardError => e
    Rails.logger.error "PAY.JP決済エラー: #{e.message}"
    @order_address.errors.add(:base, "決済処理に失敗しました: #{e.message}")
    raise
  rescue => e
    Rails.logger.error "決済処理エラー: #{e.class}: #{e.message}"
    @order_address.errors.add(:base, "決済処理に失敗しました")
    raise
  end
end
