# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_13_142454) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "periodic_exceptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.text "note"
    t.integer "one_time_task_id"
    t.integer "status"
    t.bigint "task_id", null: false
    t.datetime "updated_at", null: false
    t.index ["one_time_task_id"], name: "index_periodic_exceptions_on_one_time_task_id"
    t.index ["task_id", "date"], name: "index_periodic_exceptions_on_task_id_and_date", unique: true
    t.index ["task_id"], name: "index_periodic_exceptions_on_task_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "color", null: false
    t.datetime "created_at", null: false
    t.boolean "is_required", default: false, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["is_required"], name: "index_tags_on_is_required"
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "task_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "tag_id", null: false
    t.bigint "task_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_task_tags_on_tag_id"
    t.index ["task_id", "tag_id"], name: "index_task_tags_on_task_id_and_tag_id", unique: true
    t.index ["task_id"], name: "index_task_tags_on_task_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "due_date", null: false
    t.jsonb "periodicity_config", default: {}
    t.integer "periodicity_type"
    t.integer "status", default: 0, null: false
    t.integer "task_type", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["due_date"], name: "index_tasks_on_due_date"
    t.index ["status"], name: "index_tasks_on_status"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "auth_token"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "role", default: "user", null: false
    t.datetime "updated_at", null: false
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "periodic_exceptions", "tasks"
  add_foreign_key "periodic_exceptions", "tasks", column: "one_time_task_id"
  add_foreign_key "tags", "users"
  add_foreign_key "task_tags", "tags"
  add_foreign_key "task_tags", "tasks"
  add_foreign_key "tasks", "users"
end
