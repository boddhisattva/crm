# frozen_string_literal: true

FactoryBot.define do
  factory :customer do
    sequence(:name) { |n| "person#{n}" }
    sequence(:surname) { |n| "person#{n}_surname" }
    created_by { create(:user) }
    last_modified_by { created_by }
    identifier { SecureRandom.uuid_v7 }
  end
end
