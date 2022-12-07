class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def record_not_found(exception)
    render json: ErrorSerializer.not_found(exception.message), status: 404
  end
end
