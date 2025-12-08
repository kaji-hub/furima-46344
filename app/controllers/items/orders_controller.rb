class Items::OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item
  before_action :ensure_not_owner
  before_action :ensure_not_sold

  def new
    @order_address = OrderAddress.new
    gon.public_key = ENV['PAYJP_PUBLIC_KEY']
  end

  def create
    @order_address = OrderAddress.new(order_address_params)
    gon.public_key = ENV['PAYJP_PUBLIC_KEY']

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

  def redirect_if_owner_or_sold
    return unless @item.user_id == current_user.id || @item.order.present?

    redirect_to root_path
  end

  def order_address_params
    params.require(:order_address).permit(:postal_code, :prefecture_id, :city, :house_number, :building_name, :phone_number, :token).merge(
      item_id: params[:item_id], user_id: current_user.id
    )
  end

  def pay_item
    Payjp.api_key = ENV['PAYJP_SECRET_KEY']
    Payjp::Charge.create(
      amount: @item.price,
      card: @order_address.token,
      currency: 'jpy'
    )
  end
end
