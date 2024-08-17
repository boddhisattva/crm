# frozen_string_literal: true

module API
  module V1
    module Users
      class CustomersController < APIController
        CUSTOMERS_PER_PAGE = 10

        def index
          customers = Customer.where(created_by: params[:user_id]).page(params[:page]).per_page(CUSTOMERS_PER_PAGE)

          render json: customers, status: :ok
        end
      end
    end
  end
end
