class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.datetime :due_date, null: false
      t.integer :status, null: false, default: 0
      t.integer :task_type, null: false, default: 0
      t.integer :periodicity_type
      t.jsonb :periodicity_config, default: {}

      t.timestamps
    end
    add_index :tasks, :due_date
    add_index :tasks, :status
  end
end
