# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Customers API specs', type: :request do
  let(:user1) { create(:user, role: User.roles[:admin]) }
  let(:token) { create :access_token, application: create(:application), resource_owner_id: user1.id }

  before do
    token
  end

  describe 'POST /api/v1/admin/users' do
    let(:new_user_params) do
      {
        'user':
        {
          'email': 'user1@example.com',
          'password': 'pass123',
          'role': 'user'
        }
      }
    end

    context 'with valid params' do
      it 'creates a new customer' do
        expect do
          post '/api/v1/admin/users', params: new_user_params,
                                      headers: { 'Authorization': "Bearer #{token.token}" }
        end.to change(User, :count).by(1)

        parsed_response_body = JSON.parse(response.body)
        expect(parsed_response_body['email']).to eq('user1@example.com')

        expect(response).to have_http_status(:created)
      end
    end

    context 'when required params(example: password not specified in API request) are not passed' do
      let(:new_user_params) do
        {
          'user':
          {
            'email': 'user1@example.com',
            'role': 'user'
          }
        }
      end

      it 'returns a password can\'t be blank error & returns a HTTP unprocessable_entity status code' do
        expect do
          post '/api/v1/admin/users', params: new_user_params,
                                      headers: { 'Authorization': "Bearer #{token.token}" }
        end.not_to change(User, :count)

        parsed_response_body = JSON.parse(response.body)

        expect(parsed_response_body['errors']).to eq({ 'password' => ["can't be blank"] })
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with invalid params' do
      context 'when email specifed is invalid' do
        let(:invalid_email) { 'a random email id' }
        let(:new_user_params) do
          {
            'user':
            {
              'email': invalid_email,
              'password': 'pass123',
              'role': 'user'
            }
          }
        end

        it 'returns a email is invalid error and returns a HTTP unprocessable_entity status code' do
          expect do
            post '/api/v1/admin/users', params: new_user_params,
                                        headers: { 'Authorization': "Bearer #{token.token}" }
          end.not_to change(User, :count)

          parsed_response_body = JSON.parse(response.body)

          expect(parsed_response_body['errors']).to eq({ 'email' => ['is invalid'] })
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when logged in user attempting to access the API admin route does not have an admin role' do
      let(:user1) { create(:user, role: User.roles[:user]) }

      it 'returns with you need to be an admin to acess this API error and returns an HTTP unuathorized status code' do
        expect do
          post '/api/v1/admin/users', params: new_user_params,
                                      headers: { 'Authorization': "Bearer #{token.token}" }
        end.not_to change(User, :count)

        parsed_response_body = JSON.parse(response.body)

        expect(parsed_response_body['errors']).to eq('You need to be an admin in order to access this API')
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
