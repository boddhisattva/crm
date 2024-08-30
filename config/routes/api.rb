# frozen_string_literal: true

namespace :api do
  namespace :v1 do
    scope :users, module: :users do
      post '/', to: 'registrations#create', as: :user_registration
    end

    namespace :admin, module: :admin do
      resources :users, only: %i[create destroy update index]
    end

    resources :customers, only: %i[destroy update show create index]
  end
end
