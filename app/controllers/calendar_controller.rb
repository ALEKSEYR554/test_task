class CalendarController < ApplicationController
  before_action :require_login

  def show
    @view = params[:view] || 'month'
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    
    if @view == 'week'
      @start_date = @date.beginning_of_week(:monday)
      @end_date = @date.end_of_week(:monday)
    else
      @start_date = @date.beginning_of_month
      @end_date = @date.end_of_month
    end
    
    @tasks = current_user.tasks.includes(:tags, :periodic_exceptions)
    @calendar_data = generate_calendar_data
  end

  def day
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    @tasks = current_user.tasks.includes(:tags, :periodic_exceptions)
    @day_tasks = generate_day_tasks(@date)
  end

  private

  def generate_calendar_data
    calendar_data = {}

    # Add one-time tasks (excluding detached periodic occurrences)
    @tasks.where(task_type: :one_time).each do |task|
      date = task.due_date.to_date
      next if PeriodicException.where(one_time_task_id: task.id).exists?
      calendar_data[date] ||= []
      calendar_data[date] << task
    end

    # Add periodic task occurrences
    @tasks.where(task_type: :periodic).each do |task|
      service = PeriodicTaskService.new(task, @start_date, @end_date)
      service.occurrences.each do |occurrence|
        next if occurrence[:exception_status] == 'cancelled'
        date = occurrence[:date]
        calendar_data[date] ||= []
        calendar_data[date] << occurrence
      end
    end

    calendar_data
  end

  def generate_day_tasks(date)
    day_tasks = []

    # Add one-time tasks for this day (including detached periodic occurrences)
    @tasks.where(task_type: :one_time).where(due_date: date.beginning_of_day..date.end_of_day).each do |task|
      # Check if this one-time task is a detached periodic occurrence
      exception = PeriodicException.where(one_time_task_id: task.id).first
      if exception
        next # Skip - it will be shown as a detached occurrence below
      end
      day_tasks << { task: task, status: task.status, is_exception: false, date: date }
    end

    # Add periodic task occurrences for this day
    @tasks.where(task_type: :periodic).each do |task|
      service = PeriodicTaskService.new(task, date, date)
      service.occurrences.each do |occurrence|
        # If this occurrence is detached, show the one-time task instead
        if occurrence[:one_time_task_id]
          detached_task = Task.find_by(id: occurrence[:one_time_task_id])
          if detached_task
            day_tasks << { task: detached_task, status: detached_task.status, is_exception: true, date: date }
            next
          end
        end
        day_tasks << occurrence
      end
    end

    day_tasks.sort_by { |t| t[:task].due_date }
  end
end