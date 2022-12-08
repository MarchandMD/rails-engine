class Api::V1::Items::SearchController < ApplicationController

  def show
    render json: ItemSerializer.new(Item.search(params[:name]))
  end
end
