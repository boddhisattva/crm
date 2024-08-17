# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Customers API specs', type: :request do
  describe 'GET users/:user_id/customers' do
    let(:customer) { create(:customer) }
    let(:user1) { customer.created_by }

    context 'when authorized' do
      let(:other_customer) { create(:customer, created_by: customer.created_by) }
      let(:application) { create(:application) }
      let(:token) { create :access_token, application:, resource_owner_id: user1.id }

      before do
        token
        other_customer
      end

      it 'gets all the customers' do
        get "/api/v1/users/#{user1.id}/customers", params: {}, headers: { 'Authorization': "Bearer #{token.token}" }

        expect(response).to have_http_status(:ok)

        parsed_response_body = JSON.parse(response.body)
        expect(parsed_response_body[0]['name']).to eq('person1')
        expect(parsed_response_body[1]['name']).to eq('person2')
        expect(parsed_response_body[1]['surname']).to eq('person2_surname')
      end
    end

    context 'when unauthorized' do
      it 'fails with HTTP 401' do
        get "/api/v1/users/#{user1.id}/customers"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
