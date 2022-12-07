class Api::V1::MerchantsController < ApplicationController
  def index
    render json: MerchantSerializer.new(Merchant.all)
  end

  def show
    if params.include?(:item_id)
      render json: MerchantSerializer.new(Merchant.find_items_merchant(params[:item_id]))
    else
      render json: MerchantSerializer.new(Merchant.find(params[:id]))
    end
  end
end
