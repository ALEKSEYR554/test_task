class PeriodicTaskService
  attr_reader :task, :start_date, :end_date

  def initialize(task, start_date, end_date)
    @task = task
    @start_date = start_date.to_date
    @end_date = end_date.to_date
  end

  def occurrences
    return [] unless task.periodic?

    case task.periodicity_type
    when 'daily'
      daily_occurrences
    when 'monthly'
      monthly_occurrences
    when 'specific_dates'
      specific_dates_occurrences
    when 'even_odd'
      even_odd_occurrences
    else
      []
    end
  end

  private

  def daily_occurrences
    interval = (task.periodicity_config['interval'] || 1).to_i
    occurrences = []
    current_date = start_date

    while current_date <= end_date
      if (current_date - task.due_date.to_date).to_i % interval == 0
        occurrences << build_occurrence(current_date)
      end
      current_date += 1.day
    end
    occurrences
  end

  def monthly_occurrences
    day_of_month = task.due_date.day
    occurrences = []
    current_date = start_date.beginning_of_month

    while current_date <= end_date
      if current_date.day == day_of_month
        occurrences << build_occurrence(current_date)
      end
      current_date += 1.month
    end
    occurrences
  end

  def specific_dates_occurrences
    dates = task.periodicity_config['dates'] || []
    occurrences = []

    dates.each do |date_str|
      date = Date.parse(date_str)
      if date >= start_date && date <= end_date
        occurrences << build_occurrence(date)
      end
    end
    occurrences
  end

  def even_odd_occurrences
    even_odd = task.periodicity_config['even_odd'] # 'even' or 'odd'
    occurrences = []
    current_date = start_date

    while current_date <= end_date
      if even_odd == 'even' && current_date.day.even?
        occurrences << build_occurrence(current_date)
      elsif even_odd == 'odd' && current_date.day.odd?
        occurrences << build_occurrence(current_date)
      end
      current_date += 1.day
    end
    occurrences
  end

  def build_occurrence(date)
    exception = task.periodic_exceptions.find_by(date: date)
    status = exception ? exception.status : task.status

    {
      task: task,
      date: date,
      status: status,
      is_exception: exception.present?,
      exception_status: exception&.status,
      one_time_task_id: exception&.one_time_task_id
    }
  end
end