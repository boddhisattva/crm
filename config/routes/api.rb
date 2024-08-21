# frozen_string_literal: true

namespace :api do
  namespace :v1 do
    scope :users, module: :users do
      post '/', to: 'registrations#create', as: :user_registration
    end

    resources :users, module: :users do
      resources :customers, only: %i[index create]
    end

    namespace :admin, module: :admin do
      resources :users, only: %i[create destroy update index]
    end

    resources :customers, only: %i[destroy update show create]
  end
end

scope :api do
  scope :v1 do
    use_doorkeeper do
      skip_controllers :authorizations, :applications, :authorized_applications
    end
  end
end
