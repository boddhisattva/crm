FactoryBot.define do
  factory :customer do
    name { "first name" }
    surname { "last name" }
    created_by { create(:user) }
    last_modified_by { created_by }
  end
end
