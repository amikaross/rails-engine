class Api::V1::ItemsController < ApplicationController
  def index 
    if params[:merchant_id]
      render json: Item.where(merchant_id: params[:merchant_id])
    else
      render json: Item.all
    end
  end

  def show
    render json: Item.find(params[:id])
  end

  def create
    render json: Item.create(item_params)
  end

  def update
    render json: Item.update(params[:id], item_params)
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end