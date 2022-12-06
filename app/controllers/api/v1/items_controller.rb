class Api::V1::ItemsController < ApplicationController
  def index 
    if params[:merchant_id]
      render json: ItemSerializer.new(Item.where(merchant_id: params[:merchant_id]))
    else
      render json: ItemSerializer.new(Item.all)
    end
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id]))
  end

  def create
    render json: ItemSerializer.new(Item.create(item_params))
  end

  def update
    render json: ItemSerializer.new(Item.update(params[:id], item_params))
  end

  def destroy
    # item = Item.find(params[:id])
    # empty_invoices = item.invoices_with_one_item
    # require 'pry'; binding.pry
    # empty_invoices.delete_all
    render json: Item.destroy(params[:id])
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end