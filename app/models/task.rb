class Task < ApplicationRecord
  belongs_to :user
  has_many :task_tags, dependent: :destroy
  has_many :tags, through: :task_tags
  has_many :periodic_exceptions, dependent: :destroy

  enum :status, { new: 0, in_progress: 1, completed: 2, cancelled: 3 }, prefix: true
  enum :task_type, { one_time: 0, periodic: 1 }, prefix: true
  enum :periodicity_type, { daily: 0, monthly: 1, specific_dates: 2, even_odd: 3 }, prefix: true

  validates :title, presence: true
  validates :due_date, presence: true
  validates :status, presence: true
  validates :task_type, presence: true

  scope :for_date_range, ->(start_date, end_date) { where(due_date: start_date..end_date) }
  scope :for_status, ->(status) { where(status: status) if status.present? }

  STATUS_LABELS = {
    'new' => 'Новая',
    'in_progress' => 'В работе',
    'completed' => 'Завершена',
    'cancelled' => 'Отменена'
  }.freeze

  TASK_TYPE_LABELS = {
    'one_time' => 'Разовая',
    'periodic' => 'Периодическая'
  }.freeze

  PERIODICITY_TYPE_LABELS = {
    'daily' => 'Ежедневная',
    'monthly' => 'Ежемесячная',
    'specific_dates' => 'На конкретные даты',
    'even_odd' => 'Чётные/нечётные дни'
  }.freeze

  def status_label
    STATUS_LABELS[status] || status
  end

  def task_type_label
    TASK_TYPE_LABELS[task_type] || task_type
  end

  def periodicity_type_label
    PERIODICITY_TYPE_LABELS[periodicity_type] || periodicity_type
  end

  def periodic?
    task_type_periodic?
  end

  def one_time?
    task_type_one_time?
  end
end
