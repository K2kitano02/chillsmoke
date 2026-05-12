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

ActiveRecord::Schema[7.2].define(version: 2026_05_12_090000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "user_schedule_reflections", force: :cascade do |t|
    t.bigint "user_schedule_id", null: false
    t.date "reflected_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_schedule_id", "reflected_on"], name: "idx_on_user_schedule_id_reflected_on_7cae552cb2", unique: true
    t.index ["user_schedule_id"], name: "index_user_schedule_reflections_on_user_schedule_id"
  end

  create_table "user_schedules", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.time "scheduled_smoking_time", null: false
    t.string "label"
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_schedules_on_user_id"
  end

  create_table "user_settings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "target_daily_cigarette_count", null: false
    t.integer "baseline_daily_cigarette_count", null: false
    t.integer "pack_price", null: false
    t.integer "cigarettes_per_pack", default: 20, null: false
    t.boolean "is_oni_mode", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_settings_on_user_id", unique: true
  end

  create_table "user_smoking_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "smoked_on", null: false
    t.integer "smoking_count", default: 0, null: false
    t.integer "target_daily_cigarette_count_snapshot", null: false
    t.integer "baseline_daily_cigarette_count_snapshot", null: false
    t.integer "pack_price_snapshot", null: false
    t.integer "cigarettes_per_pack_snapshot", null: false
    t.boolean "is_oni_mode_snapshot", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "smoked_on"], name: "index_user_smoking_logs_on_user_id_and_smoked_on", unique: true
  end

  create_table "user_wishlists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.integer "price", null: false
    t.text "memo"
    t.boolean "is_purchased", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_wishlists_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "user_schedule_reflections", "user_schedules"
  add_foreign_key "user_schedules", "users"
  add_foreign_key "user_settings", "users"
  add_foreign_key "user_smoking_logs", "users"
  add_foreign_key "user_wishlists", "users"
end
