class Api::V1::Merchants::SearchController < ApplicationController
  def show
    merchant = Merchant.search(params[:name])
    if merchant
      render json: MerchantSerializer.new(merchant), status: :ok
    else
      render json: { data: { error: 'Merchant not found' } }
    end
  end
end
