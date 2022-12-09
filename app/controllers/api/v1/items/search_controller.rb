class Api::V1::Items::SearchController < ApplicationController

  def index
    render json: ItemSerializer.new(Item.search(params[:name]))
  end

  def show
    render json: ItemSerializer.new(Item.find_by('unit_price >= ?', params[:min_price]))
    # render json: ItemSerializer.new(Item.find_by('unit_price >= ?', Item.check_params(params)))
  end

  private

  def check_params
    # code here
  end
end
