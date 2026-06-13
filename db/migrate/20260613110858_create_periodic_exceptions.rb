class CreatePeriodicExceptions < ActiveRecord::Migration[8.1]
  def change
    create_table :periodic_exceptions do |t|
      t.references :task, null: false, foreign_key: true
      t.date :date, null: false
      t.integer :status
      t.text :note

      t.timestamps
    end
    add_index :periodic_exceptions, [:task_id, :date], unique: true
  end
end
