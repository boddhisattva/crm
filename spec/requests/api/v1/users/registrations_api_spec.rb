# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'User Registration API', type: :request do

  path '/api/v1/users' do

    post('Register a new user') do
      tags 'User Registration'
      consumes 'application/json'
      produces 'application/json'
      description 'Creates a new user account with the provided credentials and OAuth client ID'

      parameter name: :registration_params, in: :body, schema: {
        '$ref' => '#/components/schemas/RegistrationInput'
      }

      context 'when valid params are passed as part of the request' do
        response(200, 'successful registration') do
          let(:application) { create(:application) }
          let(:registration_params) do
            {
              email: 'user2@example.com',
              password: 'dummy_passwd',
              client_id: application.uid
            }
          end

          schema '$ref' => '#/components/schemas/RegistrationResponse'

          examples 'application/json' => {
            id: 1,
            email: 'user2@example.com',
            role: 'user',
            access_token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
            token_type: 'Bearer',
            expires_in: 7200,
            refresh_token: 'refresh_token_example',
            created_at: 1_234_567_890
          }

          it 'creates a new User and returns an access token and other user related details' do |example|
            expect { submit_request(example.metadata) }.to change(User, :count).by(1)

            assert_response_matches_metadata(example.metadata)

            # RegistrationResponse
            parsed_response_body = JSON.parse(response.body)
            expect(parsed_response_body['role']).to eq('user')
            expect(parsed_response_body['email']).to eq('user2@example.com')
            expect(parsed_response_body['access_token']).not_to be_nil
          end
        end
      end

      context 'when invalid params are passed as part of the request' do
        context 'when invalid client id is passed' do
          response(401, 'unauthorized - invalid client') do
            let(:registration_params) do
              {
                email: 'user2@example.com',
                password: 'dummy_passwd',
                client_id: 'random client id'
              }
            end

            schema '$ref' => '#/components/schemas/Error'

            examples 'application/json' => {
              error: 'Client authentication failed due to unknown client, no client authentication included, or unsupported authentication method.'
            }

            it 'fails with an unauthorized error response status & unknown client error message' do |example|
              submit_request(example.metadata)
              assert_response_matches_metadata(example.metadata)

              expect(response).to have_http_status(:unauthorized)

              parsed_response_body = JSON.parse(response.body)
              expect(parsed_response_body['error']).to eq(I18n.t('doorkeeper.errors.messages.invalid_client'))
            end
          end
        end

        context 'when an invalid email is passed' do
          response(422, 'unprocessable entity - validation errors') do
            let(:application) { create(:application) }
            let(:registration_params) do
              {
                email: 'invalid_email',
                password: 'dummy_passwd',
                client_id: application.uid
              }
            end

            schema '$ref' => '#/components/schemas/Error'

            examples 'application/json' => {
              errors: {
                email: ['is invalid']
              }
            }

            it 'fails with a unprocessable_entity error response status & an email is invalid error message' do |example|
              submit_request(example.metadata)
              assert_response_matches_metadata(example.metadata)

              expect(response).to have_http_status(:unprocessable_entity)

              parsed_response_body = JSON.parse(response.body)
              expect(parsed_response_body['errors']['email']).to include('is invalid')
            end
          end
        end
      end
    end
  end
end
