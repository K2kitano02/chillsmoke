# frozen_string_literal: true

class CreateUserScheduleReflections < ActiveRecord::Migration[7.2]
  def change
    create_table :user_schedule_reflections do |t|
      t.references :user_schedule, null: false, foreign_key: true
      t.date :reflected_on, null: false

      t.timestamps
    end

    add_index :user_schedule_reflections,
              [ :user_schedule_id, :reflected_on ],
              unique: true
  end
end
