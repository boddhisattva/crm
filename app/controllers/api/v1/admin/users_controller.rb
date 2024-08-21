# frozen_string_literal: true

module API
  module V1
    module Admin
      class UsersController < APIController
        before_action :admin?

        def create
          user = User.new(user_params)

          if user.save
            render json: ::Admin::UserSerializer.new(user).serializable_hash[:data][:attributes], status: :created
          else
            render json: { errors: user.errors }, status: :unprocessable_entity
          end
        end

        private

          def user_params
            params.require(:user).permit(:email, :password, :password_confirmation, :role)
          end
      end
    end
  end
end
