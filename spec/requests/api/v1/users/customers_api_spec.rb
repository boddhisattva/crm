# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Customers API specs', type: :request do
  describe 'GET /api/v1/users/:user_id/customers' do
    let(:user1) { create(:user) }
    let(:token) { create :access_token, application: create(:application), resource_owner_id: user1.id }

    before do
      token
    end

    context 'when one or more customers are present' do
      let(:customer) { create(:customer, created_by: user1) }
      let(:other_customer) { create(:customer, created_by: customer.created_by) }

      before do
        other_customer
      end

      it 'gets all the customers' do
        get "/api/v1/users/#{user1.id}/customers", params: {}, headers: { 'Authorization': "Bearer #{token.token}" }

        expect(response).to have_http_status(:ok)

        parsed_response_body = JSON.parse(response.body)

        expect(parsed_response_body['data'][0]['attributes']['name']).to eq(customer.name)
        expect(parsed_response_body['data'][1]['attributes']['name']).to eq(other_customer.name)
        expect(parsed_response_body['data'][1]['attributes']['surname']).to eq(other_customer.surname)
      end
    end

    context 'when no customers are present' do
      it 'returns an empty array' do
        get "/api/v1/users/#{user1.id}/customers", params: {}, headers: { 'Authorization': "Bearer #{token.token}" }

        expect(JSON.parse(response.body)).to eq([])
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST /api/v1/users/:user_id/customers' do
    let(:user1) { create(:user) }
    let(:photo_name) { 'alfred_schrock_lotus_unsplash.jpg' }
    let(:photo) { fixture_file_upload(photo_name) }
    let(:token) { create :access_token, application: create(:application), resource_owner_id: user1.id }
    let(:new_customer_params) do
      {
        'name': 'Fiona',
        'surname': 'Rainer',
        'photo': photo,
        'identifier': SecureRandom.uuid_v7
      }
    end

    before do
      token
    end

    context 'with valid params' do
      it 'creates a new customer' do
        expect do
          post "/api/v1/users/#{user1.id}/customers", params: new_customer_params,
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
        expect(parsed_response_body['photo_url']).to include(photo_name)

        expect(response).to have_http_status(:created)
      end
    end

    context 'when required params are not passed' do
      let(:new_customer_params) do
        {
          'name': 'Fiona',
          'photo': photo,
          'identifier': SecureRandom.uuid_v7
        }
      end

      it 'fails with a HTTP Bad request error' do
        expect do
          post "/api/v1/users/#{user1.id}/customers", params: new_customer_params,
                                                      headers: { 'Authorization': "Bearer #{token.token}" }
        end.not_to change(Customer, :count)

        parsed_response_body = JSON.parse(response.body)

        expect(parsed_response_body['errors']).to eq('["surname"] param(s) is/are not present')
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'with invalid params' do
      context 'when specified user as part of API request does not exist' do
        let(:invalid_user_id) { 1234 }

        it 'returns appropriate errors related nil user & also returns unprocessable_entity related error' do
          expect do
            post "/api/v1/users/#{invalid_user_id}/customers", params: new_customer_params,
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
            'name': 'Fiona',
            'surname': 'Rainer',
            'photo': photo,
            'identifier': 'random value'
          }
        end

        it 'returns identifier cannot be blank error & also returns unprocessable_entity related error' do
          expect do
            post "/api/v1/users/#{user1.id}/customers", params: new_customer_params,
                                                        headers: { 'Authorization': "Bearer #{token.token}" }
          end.not_to change(Customer, :count)

          parsed_response_body = JSON.parse(response.body)

          expect(parsed_response_body['errors']).to eq({ 'identifier' => ["can't be blank"] })
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
