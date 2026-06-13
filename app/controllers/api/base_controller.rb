module Api
  class BaseController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_api_user

    private

    def authenticate_api_user
      token = request.headers['Authorization']&.split(' ')&.last
      @current_user = User.find_by(auth_token: token) if token
      
      unless @current_user
        render json: { error: 'Не авторизован' }, status: :unauthorized
      end
    end

    def current_api_user
      @current_user
    end
  end
end