class PeriodicException < ApplicationRecord
  belongs_to :task
  belongs_to :one_time_task, class_name: 'Task', optional: true

  enum :status, { new: 0, in_progress: 1, completed: 2, cancelled: 3 }, prefix: true

  validates :date, presence: true
  validates :task_id, uniqueness: { scope: :date }

  def detached?
    one_time_task_id.present?
  end
end