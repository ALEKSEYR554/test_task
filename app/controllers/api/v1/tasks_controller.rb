module Api
  module V1
    class TasksController < Api::BaseController
      before_action :set_task, only: [:show, :update, :destroy]

      def index
        @tasks = current_api_user.tasks.includes(:tags)
        @tasks = @tasks.for_date_range(params[:start_date], params[:end_date]) if params[:start_date].present? && params[:end_date].present?
        @tasks = @tasks.for_status(params[:status]) if params[:status].present?
        @tasks = @tasks.order(due_date: :asc)
        
        render json: @tasks, include: :tags
      end

      def show
        render json: @task, include: :tags
      end

      def create
        @task = current_api_user.tasks.build(task_params)
        if @task.save
          attach_tags(@task)
          render json: @task, include: :tags, status: :created
        else
          render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @task.update(task_params)
          @task.tags.clear
          attach_tags(@task)
          render json: @task, include: :tags
        else
          render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @task.destroy
        head :no_content
      end

      private

      def set_task
        @task = current_api_user.tasks.find(params[:id])
      end

      def task_params
        params.require(:task).permit(:title, :description, :due_date, :status, :task_type, :periodicity_type, periodicity_config: [:interval, :dates, :even_odd])
      end

      def attach_tags(task)
        return unless params[:tag_ids].present?
        params[:tag_ids].each do |tag_id|
          tag = Tag.find(tag_id)
          task.tags << tag unless task.tags.include?(tag)
        end
      end
    end
  end
end