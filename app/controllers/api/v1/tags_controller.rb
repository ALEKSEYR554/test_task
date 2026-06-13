module Api
  module V1
    class TagsController < Api::BaseController
      before_action :set_tag, only: [:show, :update, :destroy]

      def index
        @tags = Tag.for_user(current_api_user)
        render json: @tags
      end

      def show
        render json: @tag
      end

      def create
        @tag = current_api_user.tags.build(tag_params)
        if @tag.save
          render json: @tag, status: :created
        else
          render json: { errors: @tag.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @tag.required?
          render json: { error: 'Нельзя редактировать обязательные теги' }, status: :forbidden
          return
        end
        
        if @tag.update(tag_params)
          render json: @tag
        else
          render json: { errors: @tag.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @tag.required?
          render json: { error: 'Нельзя удалять обязательные теги' }, status: :forbidden
          return
        end
        
        @tag.destroy
        head :no_content
      end

      private

      def set_tag
        @tag = Tag.find(params[:id])
      end

      def tag_params
        params.require(:tag).permit(:name, :color)
      end
    end
  end
end