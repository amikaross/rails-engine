class Api::V1::Merchants::SearchController < ApplicationController
  def index
    if params[:name]
      name_search(params)
    else 
      render_invalid_query_error("Name query must exist")
    end
  end

  private

    def name_search(params)
      merchants = Merchant.search_by_name(params[:name])
      if params[:name] == ""
        render_invalid_query_error("Query cannot be empty")
      else
        render json: MerchantSerializer.new(merchants)
      end
    end

end