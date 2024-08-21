# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Customer API specs', type: :request do
  let(:user1) { create(:user) }
  let(:token) { create :access_token, application: create(:application), resource_owner_id: user1.id }

  before do
    token
  end

  describe 'GET /api/v1/customers' do
    context 'when one or more customers are present' do
      let(:customer) { create(:customer, created_by: user1) }
      let(:other_customer) { create(:customer, created_by: customer.created_by) }

      before do
        other_customer
      end

      it 'gets all the customers' do
        get '/api/v1/customers', params: {}, headers: { 'Authorization': "Bearer #{token.token}" }

        parsed_response_body = JSON.parse(response.body)

        expect(parsed_response_body['data'][0]['attributes']['name']).to eq(customer.name)
        expect(parsed_response_body['data'][1]['attributes']['name']).to eq(other_customer.name)
        expect(parsed_response_body['data'][1]['attributes']['surname']).to eq(other_customer.surname)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when no customers are present' do
      it 'returns an empty array' do
        get '/api/v1/customers', params: {}, headers: { 'Authorization': "Bearer #{token.token}" }

        expect(JSON.parse(response.body)).to eq([])
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST /api/v1/customers' do
    let(:photo_name) { 'alfred_schrock_lotus_unsplash.jpg' }
    let(:photo) { fixture_file_upload(photo_name) }
    let(:new_customer_identifier) { SecureRandom.uuid_v7 }
    let(:new_customer_params) do
      {
        'customer':
        {
          'name': 'Fiona',
          'surname': 'Rainer',
          'photo': photo,
          'identifier': new_customer_identifier
        }
      }
    end

    context 'with valid params' do
      it 'creates a new customer' do
        expect do
          post '/api/v1/customers', params: new_customer_params,
                                    headers: { 'Authorization': "Bearer #{token.token}" }
        end.to change(Customer, :count).from(0).to(1)
           .and change(ActiveStorage::Blob, :count).from(0).to(1)

        latest_uploaded_image = ActiveStorage::Blob.last

        expect(latest_uploaded_image.filename).to eq(photo_name)

        parsed_response_body = JSON.parse(response.body)
        expect(parsed_response_body['name']).to eq('Fiona')
        expect(parsed_response_body['surname']).to eq('Rainer')
        expect(parsed_response_body['created_by_id']).to eq(user1.id)
        expect(parsed_response_body['last_modified_by_id']).to eq(user1.id)
        expect(parsed_response_body['identifier']).to eq(new_customer_identifier)
        expect(parsed_response_body['photo_url']).to include(photo_name)

        expect(response).to have_http_status(:created)
      end
    end

    context 'when required params(example: surname not passed in API request) are not passed' do
      let(:new_customer_params) do
        {
          'customer':
            {
              'name': 'Fiona',
              'photo': photo,
              'identifier': SecureRandom.uuid_v7
            }
        }
      end

      it 'fails with a HTTP Bad request error' do
        expect do
          post '/api/v1/customers', params: new_customer_params,
                                    headers: { 'Authorization': "Bearer #{token.token}" }
        end.not_to change(Customer, :count)

        parsed_response_body = JSON.parse(response.body)

        expect(parsed_response_body['errors']).to eq('["surname"] param(s) is/are not present')
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'with invalid params' do
      context 'when specified user as part of API request does not exist' do
        let(:token) { create :access_token, application: create(:application), resource_owner_id: invalid_user_id }
        let(:invalid_user_id) { 1234 }

        it 'returns appropriate errors related nil user & also returns unprocessable_entity related error' do
          expect do
            post '/api/v1/customers', params: new_customer_params,
                                      headers: { 'Authorization': "Bearer #{token.token}" }
          end.not_to change(Customer, :count)

          parsed_response_body = JSON.parse(response.body)

          expect(parsed_response_body['errors']).to eq({ 'created_by' => ['must exist', "can't be blank"],
                                                         'last_modified_by' => ['must exist', "can't be blank"] })
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'when passed customer identifier is an invalid UUID' do
        let(:new_customer_params) do
          {
            'customer':
              {
                'name': 'Fiona',
                'surname': 'Rainer',
                'photo': photo,
                'identifier': 'random value'
              }
          }
        end

        it 'returns identifier cannot be blank error & also returns unprocessable_entity related error' do
          expect do
            post '/api/v1/customers', params: new_customer_params,
                                      headers: { 'Authorization': "Bearer #{token.token}" }
          end.not_to change(Customer, :count)

          parsed_response_body = JSON.parse(response.body)

          expect(parsed_response_body['errors']).to eq({ 'identifier' => ["can't be blank"] })
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
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
      let(:invalid_customer_id) { '0134278965' }

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
