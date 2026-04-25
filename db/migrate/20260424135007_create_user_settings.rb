class CreateUserSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :user_settings do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :target_daily_cigarette_count, null: false
      t.integer :baseline_daily_cigarette_count, null: false
      t.integer :pack_price, null: false
      t.integer :cigarettes_per_pack, null: false, default: 20
      t.boolean :is_oni_mode, null: false, default: false

      t.timestamps
    end
  end
end
