# frozen_string_literal: true

class UserSmokingLog < ApplicationRecord
  belongs_to :user

  validates :smoked_on, presence: true, uniqueness: { scope: :user_id }
  validates :smoking_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # 保存系でログを新規作成するとき、user_setting から 5 項目をコピーする（新規行のみ。既存行の snapshot は更新しない）
  def self.snapshot_attributes_from_user_setting(user_setting)
    {
      target_daily_cigarette_count_snapshot: user_setting.target_daily_cigarette_count,
      baseline_daily_cigarette_count_snapshot: user_setting.baseline_daily_cigarette_count,
      pack_price_snapshot: user_setting.pack_price,
      cigarettes_per_pack_snapshot: user_setting.cigarettes_per_pack,
      is_oni_mode_snapshot: user_setting.is_oni_mode
    }
  end

  # 指定日の行を返す。無ければ create（snapshot 埋め）。保存操作専用。競合時は再取得する。
  def self.find_or_create_for_user_by_date!(user, smoked_on:)
    user.user_smoking_logs.find_by(smoked_on: smoked_on) || create_persisted_for_user_by_date!(user, smoked_on)
  end

  def self.create_persisted_for_user_by_date!(user, smoked_on)
    setting = user.user_setting
    raise ActiveRecord::RecordNotFound, "user_setting is required" if setting.nil?

    attrs = { smoked_on: smoked_on, smoking_count: 0 }.merge(
      snapshot_attributes_from_user_setting(setting)
    )
    user.user_smoking_logs.create!(attrs)
  rescue ActiveRecord::RecordNotUnique
    re_find_smoking_log_after_race!(user, smoked_on)
  rescue ActiveRecord::RecordInvalid => e
    raise e unless e.record.errors.of_kind?(:smoked_on, :taken)

    re_find_smoking_log_after_race!(user, smoked_on)
  end

  def self.re_find_smoking_log_after_race!(user, smoked_on)
    user.user_smoking_logs.find_by!(smoked_on: smoked_on)
  end
  private_class_method :re_find_smoking_log_after_race!
  private_class_method :create_persisted_for_user_by_date!
end
