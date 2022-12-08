class Api::V1::ItemsController < ApplicationController
  def index
    if params.has_key?(:merchant_id)
      merchant = Merchant.find(params[:merchant_id])
      render json: ItemSerializer.new(merchant.items.all)
    else
      render json: ItemSerializer.new(Item.all)
    end
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id]))
  end

  def create
    Item.create(item_params)
    render json: ItemSerializer.new(Item.last)
  end

  def update
    render json: ItemSerializer.new(Item.update(item_params))
  end

  def destroy
    item = Item.find(params[:id])
    return unless item

    item.destroy
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end
