# frozen_string_literal: true

class CreateUserSmokingLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :user_smoking_logs do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.date :smoked_on, null: false
      t.integer :smoking_count, null: false, default: 0
      t.integer :target_daily_cigarette_count_snapshot, null: false
      t.integer :baseline_daily_cigarette_count_snapshot, null: false
      t.integer :pack_price_snapshot, null: false
      t.integer :cigarettes_per_pack_snapshot, null: false
      t.boolean :is_oni_mode_snapshot, null: false

      t.timestamps
    end

    add_index :user_smoking_logs, [:user_id, :smoked_on], unique: true
  end
end
