# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Registration API specs', type: :request do

  describe 'POST /api/v1/users' do
    let(:user1) { create(:user) }

    context 'when valid params are passed as part of the request' do
      let(:application) { create(:application) }
      let(:signup_params) do
        {
          'email': 'user2@example.com',
          'password': 'dummy_passwd',
          'client_id': application.uid
        }
      end

      it 'creates a new User and returns an access token and other user related details' do
        expect { post('/api/v1/users', params: signup_params) }.to change(User, :count).by(1)

        expect(response).to have_http_status(:ok)

        parsed_response_body = JSON.parse(response.body)
        expect(parsed_response_body['role']).to eq('user')
        expect(parsed_response_body['email']).to eq('user2@example.com')
        expect(parsed_response_body['access_token']).not_to be_nil
      end
    end

    context 'when invalid params are passed as part of the request' do
      context 'when invalid client id is passed' do
        let(:params) do
          {
            'email': 'user2@example.com',
            'password': 'dummy_passwd',
            'client_id': 'random client id'
          }
        end

        it 'fails with an unauthorized error response status & unkown client error message' do
          post('/api/v1/users', params:)

          expect(response).to have_http_status(:unauthorized)

          parsed_response_body = JSON.parse(response.body)

          expect(parsed_response_body['error']).to eq(I18n.t('doorkeeper.errors.messages.invalid_client'))
        end
      end

      context 'when an invalid email is passed' do
        let(:application) { create(:application) }
        let(:params) do
          {
            'email': 'invalid_email',
            'password': 'dummy_passwd',
            'client_id': application.uid
          }
        end

        it 'fails with a unprocessable_entity error response status & an email is invalid error message' do
          post('/api/v1/users', params:)

          expect(response).to have_http_status(:unprocessable_entity)

          parsed_response_body = JSON.parse(response.body)

          expect(parsed_response_body['errors']['email']).to include('is invalid')
        end
      end
    end
  end
end
