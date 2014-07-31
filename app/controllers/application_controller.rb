require 'gds_api/exceptions'

class ApplicationController < ActionController::API
  include GDS::SSO::ControllerMethods

  before_filter :require_signin_permission!

  rescue_from GdsApi::BaseError do |exception|
    notify_airbrake(exception)
    if (exception.is_a?(GdsApi::HTTPErrorResponse) && (500..599).include?(exception.code)) ||
         exception.is_a?(GdsApi::TimedOutException)
      message = 'Service unavailable'
      render json: { status: "error", errors: [message] }, status: 503
    else
      message = "Server error"
      render json: { status: "error", errors: [message] }, status: 500
    end
  end

private
  def parse_request_body
    @parsed_request_body = JSON.parse(request.body.read)
  rescue JSON::ParserError => e
    message = "Request JSON could not be parsed: #{e.message}"
    render json: { status: "error", errors: [message] }, status: 400
  end
end
