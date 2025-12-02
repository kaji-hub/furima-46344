class ItemsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_item, only: [:show, :edit, :update, :destroy]
  before_action :ensure_owner, only: [:edit, :update, :destroy]

  def index
    @items = Item.all.order(created_at: :desc)
  end

  def show
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to root_path
    else
      @item.price = nil
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @item.update(item_params_without_user_id)
      redirect_to item_path(@item)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    redirect_to root_path
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def ensure_owner
    redirect_to root_path unless @item.user_id == current_user.id
  end

  def item_params
    params.require(:item).permit(:name, :description, :price, :category_id, :condition_id, :shipping_fee_id, :prefecture_id,
                                 :scheduled_delivery_id, :image).merge(user_id: current_user.id)
  end

  def item_params_without_user_id
    permitted_params = params.require(:item).permit(:name, :description, :price, :category_id, :condition_id,
                                                    :shipping_fee_id, :prefecture_id, :scheduled_delivery_id, :image)
    # 画像が送信されていない場合は画像パラメータを除外（既存の画像を保持）
    permitted_params.delete(:image) if params[:item][:image].blank?
    permitted_params
  end
end
