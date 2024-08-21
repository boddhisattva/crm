# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "person_#{n}@example.com" }
    password { 'foobaR12' }
    role { User.roles[:user] }
  end
end
