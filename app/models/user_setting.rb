class UserSetting < ApplicationRecord
  belongs_to :user

  validates :user_id, uniqueness: true
  validates :target_daily_cigarette_count, :baseline_daily_cigarette_count,
            :pack_price, :cigarettes_per_pack,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :baseline_daily_cigarette_count,
            comparison: { greater_than_or_equal_to: :target_daily_cigarette_count }
  # is_oni_mode は null: false, default: false なので通常は未チェックでよい
end
