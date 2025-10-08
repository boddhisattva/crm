# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('openapi').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/openapi.yml' => {
      openapi: '3.0.1',
      info: {
        title: 'CRM API V1',
        version: 'v1',
        description: 'Customer Relationship Management API Documentation'
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        },
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'www.example.com'
            }
          }
        }
      ],
      components: {
        schemas: {
          # Registration Input Schema
          RegistrationInput: {
            type: :object,
            properties: {
              email: { type: :string, format: :email, example: 'newuser@example.com' },
              password: { type: :string, format: :password, minLength: 6, example: 'password123' },
              client_id: { type: :string, example: 'your_client_id_here' }
            },
            required: %w[email password client_id]
          },

          # Registration Response Schema
          RegistrationResponse: {
            type: :object,
            additionalProperties: false,
            properties: {
              id: { type: :integer, example: 1 },
              email: { type: :string, format: :email },
              role: { type: :string, enum: %w[user admin] },
              access_token: { type: :string },
              token_type: { type: :string, example: 'Bearer' },
              expires_in: { type: :integer, example: 7200 },
              refresh_token: { type: :string },
              created_at: { type: :integer }
            }
          },

          # Customer Schema
          Customer: {
            type: :object,
            additionalProperties: false,
            properties: {
              id: { type: :integer, example: 1 },
              name: { type: :string, example: 'John' },
              surname: { type: :string, example: 'Doe' },
              photo: { nullable: true },
              identifier: { type: :string, format: :uuid, example: '01234567-89ab-cdef-0123-456789abcdef' },
              photo_url: { type: :string, format: :uri, nullable: true, example: 'http://example.com/photo.jpg' },
              created_by_id: { type: :integer, example: 1 },
              last_modified_by_id: { type: :integer, example: 2 },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: %w[id name surname identifier created_by_id last_modified_by_id created_at updated_at]
          },

          # Customer Update Input Schema (multipart/form-data)
          CustomerUpdateInput: {
            type: :object,
            properties: {
              customer: {
                type: :object,
                properties: {
                  name: { type: :string, example: 'Jane', description: 'Customer first name' },
                  surname: { type: :string, example: 'Smith', description: 'Customer last name' },
                  identifier: { type: :string, format: :uuid, example: '01234567-89ab-cdef-0123-456789abcdef', description: 'Unique customer identifier' },
                  photo: { type: :string, format: :binary, description: 'Customer photo file' }
                }
              }
            }
          },

          # Error Schema
          Error: {
            type: :object,
            properties: {
              error: { type: :string },
              errors: {
                oneOf: [
                  { type: :string },
                  {
                    type: :object,
                    additionalProperties: {
                      type: :array,
                      items: { type: :string }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
