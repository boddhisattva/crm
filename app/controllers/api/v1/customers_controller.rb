# frozen_string_literal: true

module API
  module V1
    class CustomersController < APIController
      def show
        customer = Customer.find_by(id: params[:id])

        if customer.blank?
          render json: { errors: 'No customer found with the specified id' },
                 status: :not_found
        else
          render json: CustomerSerializer.new(customer).serializable_hash[:data][:attributes], status: :ok
        end
      end

      def update
        customer = Customer.find_by(id: params[:id])
        if customer.blank?
          return render json: { errors: 'No customer found with the specified id' },
                        status: :not_found
        end

        customer.assign_attributes(customer_params)
        customer.last_modified_by_id = current_user.id

        if customer.save
          render json: CustomerSerializer.new(customer).serializable_hash[:data][:attributes], status: :ok
        else
          render json: { errors: customer.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        customer = Customer.find_by(id: params[:id])

        if customer.present?
          head :no_content if customer.destroy
        else
          render json: { errors: 'No customer found with the specified id' }, status: :not_found
        end
      end

      private

        def customer_params
          params.require(:customer).permit(:name, :surname, :photo, :identifier)
        end
    end
  end
end
