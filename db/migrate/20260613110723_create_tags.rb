class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.references :user, null: true, foreign_key: true
      t.string :name, null: false
      t.string :color, null: false
      t.boolean :is_required, null: false, default: false

      t.timestamps
    end
    add_index :tags, :is_required
  end
end
