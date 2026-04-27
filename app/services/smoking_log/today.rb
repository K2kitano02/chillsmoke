# frozen_string_literal: true

# 当日の user_smoking_log を一貫して扱う（ISSUE-31）。
# - 表示用: 行が無ければ DB へ save せず 0 本の仮想行（snapshot は現在の user_setting から埋める）
# - 永続化: 保存系操作からだけ find_or_create（snapshot は作成時の user_setting をコピー、既存行は不変）
class SmokingLog::Today
  class << self
    # ダッシュボード等の表示用。GET のみの処理から呼んでも DB 行は増えない。
    def for_display(user)
      today = Time.zone.today
      user.user_smoking_logs.find_by(smoked_on: today) || build_virtual_today(user, today)
    end

    # +1・スケジュール反映・本数保存など、保存操作からだけ呼ぶ。
    def find_or_create_persisted!(user)
      UserSmokingLog.find_or_create_for_user_by_date!(user, smoked_on: Time.zone.today)
    end
  end

  class << self
    private

    def build_virtual_today(user, today)
      setting = user.user_setting
      raise ActiveRecord::RecordNotFound, "user_setting is required" if setting.nil?

      user.user_smoking_logs.build(
        { smoked_on: today, smoking_count: 0 }.merge(
          UserSmokingLog.snapshot_attributes_from_user_setting(setting)
        )
      )
    end
  end
end
