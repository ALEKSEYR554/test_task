class AddOneTimeTaskIdToPeriodicExceptions < ActiveRecord::Migration[8.1]
  def change
    add_column :periodic_exceptions, :one_time_task_id, :integer
    add_index :periodic_exceptions, :one_time_task_id
    add_foreign_key :periodic_exceptions, :tasks, column: :one_time_task_id
  end
end
