# frozen_string_literal: true

module Admin
  class UserSerializer
    include JSONAPI::Serializer
    attributes :email, :role
  end
end
