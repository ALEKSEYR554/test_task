class TasksController < ApplicationController
  before_action :require_login
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  def index
    @tasks = current_user.tasks.includes(:tags)
    @tasks = @tasks.for_date_range(params[:start_date], params[:end_date]) if params[:start_date].present? && params[:end_date].present?
    @tasks = @tasks.for_status(params[:status]) if params[:status].present?
    @tasks = @tasks.order(due_date: :asc)
  end

  def show
  end

  def new
    @task = current_user.tasks.build(due_date: Time.current)
  end

  def edit
  end

  def create
    @task = current_user.tasks.new(task_params.except(:tag_ids))
    if @task.save
      sync_tags(@task)
      redirect_to @task, notice: 'Задача успешно создана.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params.except(:tag_ids))
      sync_tags(@task)
      redirect_to @task, notice: 'Задача успешно обновлена.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_url, notice: 'Задача успешно удалена.'
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:id])
  end

  def task_params
    raw = params.require(:task).permit(:title, :description, :due_date, :status, :task_type, :periodicity_type, tag_ids: [], periodicity_config: [:interval, :even_odd, :dates_input])
    
    config = {}
    raw_config = raw[:periodicity_config] || {}
    
    config['interval'] = raw_config[:interval] if raw_config[:interval].present?
    config['even_odd'] = raw_config[:even_odd] if raw_config[:even_odd].present?
    
    if raw_config[:dates_input].present?
      config['dates'] = raw_config[:dates_input].split(',').map(&:strip).reject(&:blank?)
    end
    
    raw[:periodicity_config] = config
    raw
  end

  def sync_tags(task)
    tag_ids = params[:task][:tag_ids]
    if tag_ids.is_a?(Array)
      tag_ids = tag_ids.reject(&:blank?).map(&:to_i)
    else
      tag_ids = []
    end
    task.tag_ids = tag_ids
  end
end