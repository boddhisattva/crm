# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Customers API specs', type: :request do
  let(:user1) { create(:user) }
  let(:token) { create :access_token, application: create(:application), resource_owner_id: user1.id }

  before do
    token
  end

  describe 'GET /api/v1/customers/:customer_id' do
    context 'when customer exists' do
      let(:customer) { create(:customer, created_by: user1, identifier: new_customer_identifier) }
      let(:new_customer_identifier) { SecureRandom.uuid_v7 }

      before do
        customer
      end

      it 'returns customer details' do
        get "/api/v1/customers/#{customer.id}", params: {},
                                                headers: { 'Authorization': "Bearer #{token.token}" }

        parsed_response_body = JSON.parse(response.body)

        expect(parsed_response_body['name']).to eq(customer.name)
        expect(parsed_response_body['surname']).to eq(customer.surname)
        expect(parsed_response_body['photo_url']).to include('faith_can_move_mountains_rachel_unsplash.jpg')
        expect(parsed_response_body['identifier']).to eq(new_customer_identifier)
        expect(parsed_response_body['created_by_id']).to eq(user1.id)
        expect(parsed_response_body['last_modified_by_id']).to eq(user1.id)
        expect(parsed_response_body['created_at']).not_to be_nil
        expect(parsed_response_body['updated_at']).not_to be_nil
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when customer does not exist' do
      let(:invalid_customer_id) { '1342' }

      it 'returns an appropriate customer not found error message & not found status code' do
        get "/api/v1/customers/#{invalid_customer_id}", params: {},
                                                        headers: { 'Authorization': "Bearer #{token.token}" }

        parsed_response_body = JSON.parse(response.body)

        expect(parsed_response_body['errors']).to eq('No customer found with the specified id')
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PUT /api/v1/customers/:customer_id' do
    context 'when customer exists' do
      let(:customer) { create(:customer, created_by: user1) }
      let(:photo) { fixture_file_upload('faith_can_move_mountains_rachel_unsplash.jpg') }
      let(:user2) { create(:user) }
      let(:token) { create :access_token, application: create(:application), resource_owner_id: user2.id }
      let(:new_customer_identifier) { SecureRandom.uuid_v7 }
      let(:update_customer_params) do
        {
          'customer': {
            'surname': 'Rainer',
            'photo': photo,
            'identifier': new_customer_identifier
          }
        }
      end

      before { customer }

      it 'updates the customer record & updates the last_modified_by user id f for the same' do
        expect(customer.last_modified_by_id).to eq(user1.id)

        put "/api/v1/customers/#{customer.id}", params: update_customer_params,
                                                headers: { 'Authorization': "Bearer #{token.token}" }

        parsed_response_body = JSON.parse(response.body)

        expect(customer.reload.last_modified_by_id).to eq(user2.id)
        expect(parsed_response_body['surname']).to eq('Rainer')
        expect(parsed_response_body['photo_url']).to include('faith_can_move_mountains_rachel_unsplash.jpg')
        expect(parsed_response_body['identifier']).to eq(new_customer_identifier)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when customer does not exist(example: soft deleted customer)' do
      let(:customer) { create(:customer, created_by: user1) }
      let(:photo) { fixture_file_upload('faith_can_move_mountains_rachel_unsplash.jpg') }
      let(:user2) { create(:user) }
      let(:token) { create :access_token, application: create(:application), resource_owner_id: user2.id }
      let(:new_customer_identifier) { SecureRandom.uuid_v7 }
      let(:update_customer_params) do
        {
          'customer': {
            'surname': 'Rainer',
            'photo': photo,
            'identifier': new_customer_identifier
          }
        }
      end

      before do
        customer.destroy # soft delete the customer
      end

      it 'returns an appropriate customer not found error message & not found status code' do
        put "/api/v1/customers/#{customer.id}", params: update_customer_params,
                                                headers: { 'Authorization': "Bearer #{token.token}" }

        parsed_response_body = JSON.parse(response.body)

        expect(parsed_response_body['errors']).to eq('No customer found with the specified id')
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when we have one or more invalid update customer params - example invalid identifier passed' do
      let(:customer) { create(:customer, created_by: user1) }
      let(:photo) { fixture_file_upload('faith_can_move_mountains_rachel_unsplash.jpg') }
      let(:user2) { create(:user) }
      let(:token) { create :access_token, application: create(:application), resource_owner_id: user2.id }
      let(:new_customer_identifier) { 'a random invalid UUID' }
      let(:update_customer_params) do
        {
          'customer': {
            'surname': 'Rainer',
            'photo': photo,
            'identifier': new_customer_identifier
          }
        }
      end

      before { customer }

      it 'returns an appropriate customer not found error message & not found status code' do
        put "/api/v1/customers/#{customer.id}", params: update_customer_params,
                                                headers: { 'Authorization': "Bearer #{token.token}" }

        parsed_response_body = JSON.parse(response.body)

        expect(parsed_response_body['errors']).to eq({ 'identifier' => ["can't be blank"] })
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /api/v1/customers/:customer_id' do
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

        expect(parsed_response_body['errors']).to eq('No customer found with the specified id')
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
