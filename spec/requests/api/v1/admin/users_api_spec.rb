# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User API specs', type: :request do
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
      it 'creates a new user' do
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

      it 'returns with you need to be an admin to access this API error and returns an HTTP unuathorized status code' do
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

  describe 'DELETE /api/v1/admin/users/:user_id' do
    context 'when user exists' do
      let(:user) { create(:user) }

      before { user }

      it 'soft deletes the user record & updates the deleted_at timestamp for the same' do
        expect(user.deleted_at).to be_nil

        expect do
          delete "/api/v1/admin/users/#{user.id}", params: {},
                                                   headers: { 'Authorization': "Bearer #{token.token}" }
        end.to change(User, :count).by(-1)

        soft_deleted_user = User.with_deleted.find_by(id: user.id)

        expect(soft_deleted_user.deleted_at).not_to be_nil
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when user does not exist' do
      let(:invalid_user_id) { '0134278965' }

      it 'returns an appropriate user not found error message & not found status code' do
        expect do
          delete "/api/v1/admin/users/#{invalid_user_id}", params: {},
                                                           headers: { 'Authorization': "Bearer #{token.token}" }
        end.not_to change(User, :count)

        parsed_response_body = JSON.parse(response.body)

        expect(parsed_response_body['errors']).to eq('No user found with the specified id')
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when logged in user attempting to access the API admin route does not have an admin role' do
      let(:user1) { create(:user, role: User.roles[:user]) }
      let(:user) { create(:user) }

      before do
        user
      end

      it 'returns with you need to be an admin to access this API error and returns an HTTP unuathorized status code' do
        expect do
          delete "/api/v1/admin/users/#{user.id}", params: {},
                                                   headers: { 'Authorization': "Bearer #{token.token}" }
        end.not_to change(User, :count)

        parsed_response_body = JSON.parse(response.body)

        expect(parsed_response_body['errors']).to eq('You need to be an admin in order to access this API')
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when logged in admin user tries to soft delete their own account' do
      it 'soft deletes the user record & updates the deleted_at timestamp for the same' do
        expect(user1.deleted_at).to be_nil

        expect do
          delete "/api/v1/admin/users/#{user1.id}", params: {},
                                                    headers: { 'Authorization': "Bearer #{token.token}" }
        end.to change(User, :count).by(-1)

        soft_deleted_user = User.with_deleted.find_by(id: user1.id)

        expect(soft_deleted_user.deleted_at).not_to be_nil
        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe 'PUT /api/v1/admin/users/:user_id' do
    context 'when user exists' do
      let(:user) { create(:user, role: 'user') }
      let(:new_email) { 'user1@example.com' }
      let(:update_user_params) do
        {
          'user': {
            'email': new_email,
            'role': 'admin'
          }
        }
      end

      before { user }

      it 'updates the user record & updates the last_modified_by user id f for the same' do
        put "/api/v1/admin/users/#{user.id}", params: update_user_params,
                                              headers: { 'Authorization': "Bearer #{token.token}" }

        parsed_response_body = JSON.parse(response.body)

        expect(parsed_response_body['email']).to eq(new_email)
        expect(parsed_response_body['role']).to eq('admin')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user does not exist(example: soft deleted user)' do
      let(:user) { create(:user, role: 'user') }
      let(:new_email) { 'user1@example.com' }
      let(:update_user_params) do
        {
          'user': {
            'email': new_email,
            'role': 'admin'
          }
        }
      end

      before do
        user.destroy # soft delete the user
      end

      it 'returns an appropriate user not found error message & not found status code' do
        put "/api/v1/admin/users/#{user.id}", params: update_user_params,
                                              headers: { 'Authorization': "Bearer #{token.token}" }

        parsed_response_body = JSON.parse(response.body)

        expect(parsed_response_body['errors']).to eq('No user found with the specified id')
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with invalid params' do
      context 'when email specifed is invalid' do
        let(:user) { create(:user, role: 'user') }
        let(:invalid_email) { 'a random email id' }
        let(:update_user_params) do
          {
            'user':
            {
              'email': invalid_email
            }
          }
        end

        it 'returns a email is invalid error and returns a HTTP unprocessable_entity status code' do
          put "/api/v1/admin/users/#{user.id}", params: update_user_params,
                                                headers: { 'Authorization': "Bearer #{token.token}" }

          parsed_response_body = JSON.parse(response.body)

          expect(parsed_response_body['errors']).to eq({ 'email' => ['is invalid'] })
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when logged in user attempting to access the API admin route does not have an admin role' do
      let(:user1) { create(:user, role: User.roles[:user]) }
      let(:user) { create(:user, role: 'user') }
      let(:new_email) { 'user1@example.com' }
      let(:update_user_params) do
        {
          'user': {
            'email': new_email,
            'role': 'admin'
          }
        }
      end

      it 'returns with you need to be an admin to access this API error and returns an HTTP unuathorized status code' do
        put "/api/v1/admin/users/#{user.id}", params: update_user_params,
                                              headers: { 'Authorization': "Bearer #{token.token}" }

        parsed_response_body = JSON.parse(response.body)

        expect(parsed_response_body['errors']).to eq('You need to be an admin in order to access this API')
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user tries to update their own details' do
      let(:new_email) { 'user12@example.com' }
      let(:update_user_params) do
        {
          'user': {
            'email': new_email
          }
        }
      end

      it 'updates the user details successfully' do
        put "/api/v1/admin/users/#{user1.id}", params: update_user_params,
                                               headers: { 'Authorization': "Bearer #{token.token}" }

        parsed_response_body = JSON.parse(response.body)

        expect(parsed_response_body['email']).to eq(new_email)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /api/v1/users/:user_id/customers' do
    context 'when one or more customers are present' do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }

      before do
        user
        other_user
      end

      it 'gets all the customers' do
        get '/api/v1/admin/users', params: {}, headers: { 'Authorization': "Bearer #{token.token}" }

        parsed_response_body = JSON.parse(response.body)

        expect(parsed_response_body['data'][0]['attributes']['email']).to eq(user1.email)
        expect(parsed_response_body['data'][0]['attributes']['role']).to eq(user1.role)
        expect(parsed_response_body['data'][1]['attributes']['email']).to eq(user.email)
        expect(parsed_response_body['data'][1]['attributes']['role']).to eq(user.role)
        expect(parsed_response_body['data'][2]['attributes']['email']).to eq(other_user.email)
        expect(parsed_response_body['data'][2]['attributes']['role']).to eq(other_user.role)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when logged in user attempting to access the API admin route does not have an admin role' do
      let(:user1) { create(:user, role: User.roles[:user]) }

      it 'returns with you need to be an admin to access this API error and returns an HTTP unuathorized status code' do
        get '/api/v1/admin/users', params: {},
                                   headers: { 'Authorization': "Bearer #{token.token}" }

        parsed_response_body = JSON.parse(response.body)

        expect(parsed_response_body['errors']).to eq('You need to be an admin in order to access this API')
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
