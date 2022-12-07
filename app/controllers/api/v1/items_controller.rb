class Api::V1::ItemsController < ApplicationController
  def index 
    if params[:merchant_id] && Merchant.find(params[:merchant_id])
      render json: ItemSerializer.new(Item.where(merchant_id: params[:merchant_id]))
    else
      render json: ItemSerializer.new(Item.all)
    end
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id]))
  end

  def create
    merchant = Merchant.find(params[:item][:merchant_id])
    item = merchant.items.new(item_params)
    if item.save
      render json: ItemSerializer.new(item), status: :created 
    else
      render json: ErrorSerializer.missing_attributes(item.errors.full_messages), status: :bad_request
    end
  end

  def update
    Merchant.find(params[:merchant_id]) if params[:merchant_id]
    render status: :created, json: ItemSerializer.new(Item.update(params[:id], item_params))
  end

  def destroy
    render json: Item.destroy(params[:id])
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end