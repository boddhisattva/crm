# frozen_string_literal: true

class APIController < ApplicationController
  # equivalent of authenticate_user! on devise, but this one will check the oauth token
  before_action :doorkeeper_authorize!

  # Skip checking CSRF token authenticity for API requests.
  skip_before_action :verify_authenticity_token

  # Set response type
  respond_to :json

  def current_user
    return unless doorkeeper_token

    @current_user ||= User.find_by(id: doorkeeper_token[:resource_owner_id])
  end

  def admin?
    return if current_user&.admin?

    render json: { errors: 'You need to be an admin in order to access this API' },
           status: :unauthorized
  end
end
