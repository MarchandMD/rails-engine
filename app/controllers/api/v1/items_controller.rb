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
    item = Item.new(item_params)

    if item.save
      render json: ItemSerializer.new(Item.last), status: 201
    else
      render json: { "error": "incomplete submission" }, status: :not_found
    end
  end

  def update
    item = Item.find(params[:id])
    if item.update(item_params)
      render json: ItemSerializer.new(item), status: :created
    else
      # not being covered by tests
      render json: { "error": "not found" }, status: 404
    end
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
