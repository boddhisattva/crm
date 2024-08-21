# frozen_string_literal: true

module API
  module V1
    module Admin
      class UsersController < APIController
        USERS_PER_PAGE = 10

        before_action :admin?

        def index
          users = User.page(params[:page]).per_page(USERS_PER_PAGE)

          return render json: [], status: :ok if users.blank?

          render json: ::Admin::UserSerializer.new(users).serializable_hash, status: :ok
        end

        def create
          user = User.new(user_params)

          if user.save
            render json: ::Admin::UserSerializer.new(user).serializable_hash[:data][:attributes], status: :created
          else
            render json: { errors: user.errors }, status: :unprocessable_entity
          end
        end

        def update
          user = User.find_by(id: params[:id])

          if user.blank?
            return render json: { errors: 'No user found with the specified id' },
                          status: :not_found
          end

          if user.update(user_params)
            render json: ::Admin::UserSerializer.new(user).serializable_hash[:data][:attributes], status: :ok
          else
            render json: { errors: user.errors }, status: :unprocessable_entity
          end
        end

        def destroy
          user = User.find_by(id: params[:id])

          if user.present?
            head :no_content if user.destroy
          else
            render json: { errors: 'No user found with the specified id' }, status: :not_found
          end
        end

        private

          def user_params
            params.require(:user).permit(:email, :password, :role)
          end
      end
    end
  end
end
