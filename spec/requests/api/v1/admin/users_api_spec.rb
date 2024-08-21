# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Customers API specs', type: :request do
  let(:user1) { create(:user, role: User.roles[:admin]) }
  let(:token) { create :access_token, application: create(:application), resource_owner_id: user1.id }

  before do
    token
  end

  describe 'POST /api/v1/admin/users' do # TODO: Add specs for other scenarios of users#create
    let(:new_user_params) do
      {
        'user':
        {
          'email': 'user1@example.com',
          'password': 'pass123',
          'password_confirmation': 'pass123',
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

    context 'with invalid params' do
      let(:new_user_params) do
        {
          'user':
          {
            'email': 'user1@example.com',
            'password': 'pass123',
            'password_confirmation': 'pass123',
            'role': 'user'
          }
        }
      end

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
  end
end
