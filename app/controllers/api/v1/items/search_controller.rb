class Api::V1::Items::SearchController < ApplicationController
  def show
    search(params, "show")
  end

  def index
    search(params, "index")
  end

  private

    def search(params, result_type)
      if (params[:min_price] || params[:max_price]) && params[:name]
        render_invalid_query_error("Name and price can't be queried simultaneously")
      elsif params[:name] == ""
        render_invalid_query_error("Query cannot be empty")
      elsif params[:name]
        name_search(params, result_type)
      elsif params[:min_price] || params[:max_price]
        price_search(params)
      else 
        render_invalid_query_error("Name or Price query must exist")
      end
    end

    def name_search(params, result_type)
      items = Item.search_by_name(params[:name])
      if result_type == "show"
        render_json_for_one_item(items)
      else
        render json: ItemSerializer.new(items)
      end
    end

    def price_search(params)
      items = Item.search_by_price(params[:min_price], params[:max_price])
      if params[:min_price] == "" || params[:max_price] == ""
        render_invalid_query_error("Query cannot be empty")
      elsif (params[:min_price] && params[:max_price]) && params[:min_price] > params[:max_price]
        render_invalid_query_error("Max price must be greater than min price")
      elsif params[:min_price].to_i < 0 || params[:max_price].to_i < 0 
        render_invalid_query_error("Price cannot be less than 0")
      else
        render_json_for_one_item(items)
      end
    end

    def render_json_for_one_item(items)
      if items.empty? 
        render json: ErrorSerializer.no_matching_object
      else
        render json: ItemSerializer.new(items.first)
      end
    end
end