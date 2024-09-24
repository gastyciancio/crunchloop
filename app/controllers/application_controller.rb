class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  rescue_from ActionController::UnknownFormat, with: :raise_not_found
  rescue_from ActiveRecord::RecordNotFound, with: :raise_not_found_item

  def raise_not_found
    raise ActionController::RoutingError.new('Not supported format')
  end

  def raise_not_found_item
    render json: { error: 'Could not find item' }, status: :not_found
  end
end
