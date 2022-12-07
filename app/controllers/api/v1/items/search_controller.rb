class Api::V1::Items::SearchController < ApplicationController
  def show
    if (params[:min_price] || params[:max_price]) && params[:name]
      render json: ErrorSerializer.invalid_query_params("Name and price can't be queried simultaneously"), status: :bad_request
    elsif params[:name]
      name_search(params)
    elsif params[:min_price] || params[:max_price]
      price_search(params)
    else 
      render json: ErrorSerializer.invalid_query_params("Name or Price query must exist"), status: :bad_request
    end
  end

  private

    def name_search(params)
      items = Item.search_by_name(params[:name])
      if params[:name] == ""
        render json: ErrorSerializer.invalid_query_params("Query cannot be empty"), status: :bad_request
      else
        render_json(items)
      end
    end

    def price_search(params)
      items = Item.search_by_price(params[:min_price], params[:max_price])
      if params[:min_price] == "" || params[:max_price] == ""
        render json: ErrorSerializer.invalid_query_params("Query cannot be empty"), status: :bad_request
      elsif params[:min_price].to_i < 0 || params[:max_price].to_i < 0 
        render json: ErrorSerializer.invalid_query_params("Price cannot be less than 0"), status: :bad_request
      else
        render_json(items)
      end
    end

    def render_json(items)
      if items.empty? 
        render json: ErrorSerializer.no_matching_object
      else
        render json: ItemSerializer.new(items.first)
      end
    end
end