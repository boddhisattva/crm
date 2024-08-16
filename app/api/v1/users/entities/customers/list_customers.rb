# frozen_string_literal: true

module V1
  module Users
    module Entities
      module Customers
        class ListCustomers < Grape::Entity
          expose :name, documentation: { type: 'String', desc: 'Name of a customer' }
          expose :surname, documentation: { type: 'String', desc: 'Surname of a customer' }
        end
      end
    end
  end
end
