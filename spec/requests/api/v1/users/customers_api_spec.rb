# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V1::Users::CustomersAPI', type: :request do
  describe 'GET users/:user_id/customers' do
    context 'when required params are present' do # TODO: update this later
      let(:customer) { create(:customer) }
      let(:other_customer) { create(:customer, created_by: customer.created_by) }
      let(:user1) { customer.created_by }

      before do
        other_customer
      end

      it 'gets all the customers' do
        get "/v1/users/#{user1.id}/customers"

        expect(response.status).to eq(200)

        parsed_response_body = JSON.parse(response.body)
        expect(parsed_response_body[0]['name']).to eq('person1')
        expect(parsed_response_body[1]['name']).to eq('person2')
        expect(parsed_response_body[1]['surname']).to eq('person2_surname')
      end
    end
  end
end
