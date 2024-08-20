# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Customers API specs', type: :request do
  describe 'DELETE /api/v1/customers/:customer_id' do
    let(:user1) { create(:user) }
    let(:token) { create :access_token, application: create(:application), resource_owner_id: user1.id }

    before do
      token
    end

    context 'when customer exists' do
      let(:customer) { create(:customer, created_by: user1) }

      before { customer }

      it 'soft deletes the customer record & updates the deleted_at timestamp for the same' do
        expect(customer.deleted_at).to be_nil

        expect do
          delete "/api/v1/customers/#{customer.id}", params: {},
                                                     headers: { 'Authorization': "Bearer #{token.token}" }
        end.to change(Customer, :count).from(1).to(0)

        soft_deleted_customer = Customer.with_deleted.find_by(id: customer.id)

        expect(soft_deleted_customer.deleted_at).not_to be_nil
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when customer does not exist' do
      let(:invalid_customer_id) { '1342' }

      it 'returns an appropriate customer not found error message & not found status code' do
        expect do
          delete "/api/v1/customers/#{invalid_customer_id}", params: {},
                                                             headers: { 'Authorization': "Bearer #{token.token}" }
        end.not_to change(Customer, :count)

        parsed_response_body = JSON.parse(response.body)

        expect(parsed_response_body['errors']).to eq('No customer found based on the specified id')
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
