# frozen_string_literal: true

module API
  module V1
    module Users
      class CustomersController < APIController
        def index
          customers = Customer.where(created_by: params[:user_id]) # TODO: Add Pagination later

          render json: customers, status: :ok
        end
      end
    end
  end
end
