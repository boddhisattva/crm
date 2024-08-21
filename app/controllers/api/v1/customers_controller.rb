# frozen_string_literal: true

module API
  module V1
    class CustomersController < APIController
      CUSTOMERS_PER_PAGE = 10

      before_action :require_all_customer_params, only: %i[create]

      def index
        customers = Customer.includes(photo_attachment: :blob)
                            .page(params[:page]).per_page(CUSTOMERS_PER_PAGE)

        return render json: [], status: :ok if customers.blank?

        render json: CustomerSerializer.new(customers).serializable_hash, status: :ok
      end

      def create
        customer = Customer.new(customer_params)
        customer.created_by_id = current_user&.id
        customer.last_modified_by_id = current_user&.id

        if customer.save
          render json: CustomerSerializer.new(customer).serializable_hash[:data][:attributes], status: :created
        else
          render json: { errors: customer.errors }, status: :unprocessable_entity
        end
      end

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

        def require_all_customer_params
          required_customer_params = %w[name surname photo identifier]
          customer_params_keys = customer_params.keys

          return if required_customer_params.all? { |required_param| customer_params_keys.include?(required_param) }

          render json: { errors: "#{required_customer_params - customer_params.keys} param(s) is/are not present" },
                 status: :bad_request
        end
    end
  end
end
