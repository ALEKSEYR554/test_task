class PeriodicOccurrenceController < ApplicationController
  before_action :require_login

  def cancel
    task_id = params[:task_id]
    date = Date.parse(params[:date])
    task = current_user.tasks.find(task_id)

    unless task.periodic?
      redirect_to calendar_path(date: date), alert: 'Задача не является периодической.'
      return
    end

    exception = task.periodic_exceptions.find_or_initialize_by(date: date)
    exception.status = :cancelled
    if exception.save
      redirect_to calendar_day_path(date: date), notice: 'Вхождение задачи отменено.'
    else
      redirect_to calendar_day_path(date: date), alert: 'Не удалось отменить вхождение.'
    end
  end

  def edit
    @task = current_user.tasks.find(params[:task_id])
    @date = Date.parse(params[:date])
    @original_task = @task

    unless @task.periodic?
      redirect_to calendar_path(date: @date), alert: 'Задача не является периодической.'
      return
    end

    exception = @task.periodic_exceptions.find_by(date: @date)
    if exception&.detached?
      redirect_to edit_task_path(exception.one_time_task), notice: 'Это вхождение уже изменено.'
      return
    end

    @task = current_user.tasks.new(
      title: @task.title,
      description: @task.description,
      due_date: @date,
      status: exception&.status || @task.status,
      task_type: :one_time,
      periodicity_type: nil,
      periodicity_config: {}
    )
    @task.tags = @original_task.tags
  end

  def update
    @original_task = current_user.tasks.find(params[:task_id])
    @date = Date.parse(params[:date])

    unless @original_task.periodic?
      redirect_to calendar_path(date: @date), alert: 'Задача не является периодической.'
      return
    end

    new_task = current_user.tasks.new(task_params)
    new_task.task_type = :one_time
    new_task.due_date = @date

    if new_task.save
      tag_ids = params[:task][:tag_ids]
      if tag_ids.is_a?(Array)
        new_task.tag_ids = tag_ids.reject(&:blank?).map(&:to_i)
      else
        new_task.tag_ids = @original_task.tag_ids
      end

      exception = @original_task.periodic_exceptions.find_or_initialize_by(date: @date)
      exception.status = :cancelled
      exception.one_time_task_id = new_task.id
      exception.save

      redirect_to calendar_day_path(date: @date), notice: 'Создана отдельная задача на эту дату.'
    else
      @task = new_task
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def task_params
    params.require(:task).permit(:title, :description, :due_date, :status, :task_type, :periodicity_type, tag_ids: [], periodicity_config: [:interval, :even_odd, :dates_input])
  end
end