# frozen_string_literal: true

class CreateUserSchedules < ActiveRecord::Migration[7.2]
  def change
    create_table :user_schedules do |t|
      t.references :user, null: false, foreign_key: true
      t.time :scheduled_smoking_time, null: false
      t.string :label
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end
  end
end
