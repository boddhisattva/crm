# frozen_string_literal: true

module API
  module V1
    class CustomersController < APIController
      def destroy
        customer = Customer.find_by(id: params[:id])

        if customer.present?
          head :no_content if customer.destroy
        else
          render json: { errors: 'No customer found based on the specified id' }, status: :not_found
        end
      end
    end
  end
end
