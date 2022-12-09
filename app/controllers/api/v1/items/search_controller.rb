class Api::V1::Items::SearchController < ApplicationController

  def index
    render json: ItemSerializer.new(Item.search(params[:name]))
  end
end
