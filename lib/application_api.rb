# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

class ApplicationAPI < Grape::API
  format :json

  helpers Doorkeeper::Grape::Helpers

  before do
    doorkeeper_authorize!
  end

  # helper method to access the current user from the token
  def current_user
    return unless doorkeeper_token

    @current_user ||= User.find_by(id: doorkeeper_token[:resource_owner_id])
  end
end
