# frozen_string_literal: true

class CustomerSerializer
  include JSONAPI::Serializer
  attributes :name, :surname, :photo, :identifier, :created_by_id, :last_modified_by_id, :photo_url, :created_at,
             :updated_at
end
