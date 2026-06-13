module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :verify_authenticity_token

      def token
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          render json: { auth_token: user.auth_token, name: user.name, role: user.role }
        else
          render json: { error: 'Неверный email или пароль' }, status: :unauthorized
        end
      end
    end
  end
end