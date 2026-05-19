class ReplaceUserScheduleTimeWithMinutes < ActiveRecord::Migration[7.2]
  def up
    add_column :user_schedules, :scheduled_smoking_minutes, :integer

    execute <<~SQL.squish
      UPDATE user_schedules
      SET scheduled_smoking_minutes =
        (((EXTRACT(HOUR FROM scheduled_smoking_time)::integer + 9) % 24) * 60)
        + EXTRACT(MINUTE FROM scheduled_smoking_time)::integer
    SQL

    change_column_null :user_schedules, :scheduled_smoking_minutes, false
    add_check_constraint :user_schedules,
                         "scheduled_smoking_minutes >= 0 AND scheduled_smoking_minutes < 1440",
                         name: "chk_user_schedules_minutes_range"
    remove_column :user_schedules, :scheduled_smoking_time
  end

  def down
    add_column :user_schedules, :scheduled_smoking_time, :time

    execute <<~SQL.squish
      UPDATE user_schedules
      SET scheduled_smoking_time =
        make_time(((scheduled_smoking_minutes / 60 + 15) % 24), scheduled_smoking_minutes % 60, 0)
    SQL

    change_column_null :user_schedules, :scheduled_smoking_time, false
    remove_check_constraint :user_schedules, name: "chk_user_schedules_minutes_range"
    remove_column :user_schedules, :scheduled_smoking_minutes
  end
end
