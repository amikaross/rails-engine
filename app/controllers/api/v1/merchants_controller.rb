class Api::V1::MerchantsController < ApplicationController
  def index 
    if params[:item_id]
      render json: Item.find(params[:item_id]).merchant
    else
      render json: Merchant.all
    end
  end

  def show 
    render json: Merchant.find(params[:id])
  end
end