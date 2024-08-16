# frozen_string_literal: true

module V1
  module Users
    class CustomersAPI < ApplicationAPI
      namespace :users do
        desc 'List all Customers', { success: V1::Users::Entities::Customers::ListCustomers }

        params do
          requires :user_id, type: Integer, documentation: { type: 'Integer', desc: 'User id' }
        end

        get ':user_id/customers' do
          customers = Customer.where(created_by: params[:user_id]) # TODO: Add Pagination later
          present customers, with: V1::Users::Entities::Customers::ListCustomers
        end
      end
    end
  end
end
