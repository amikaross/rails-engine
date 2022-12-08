class Api::V1::Merchants::SearchController < ApplicationController
  def index
    search(params, "index")
  end

  def show
    search(params, "show")
  end

  private

    def search(params, result_type)
      if params[:name] == ""
        render_invalid_query_error("Query cannot be empty")
      elsif params[:name]
        name_search(params, result_type)
      else 
        render_invalid_query_error("Name query must exist")
      end
    end

    def name_search(params, result_type)
      merchants = Merchant.search_by_name(params[:name])
      if result_type == "show"
        render_json_for_one_merchant(merchants)
      else
        render json: MerchantSerializer.new(merchants)
      end
    end

    def render_json_for_one_merchant(merchants)
      if merchants.empty? 
        render json: ErrorSerializer.no_matching_object
      else
        render json: MerchantSerializer.new(merchants.first)
      end
    end

end