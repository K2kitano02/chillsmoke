# frozen_string_literal: true

class UserSmokingLogsController < ApplicationController
  # ISSUE-32: 今日の +1 記録（保存操作。GET では当日行を作らない）
  def increment_today
    SmokingLog::Today.increment_persisted!(current_user)
    redirect_to dashboard_path, notice: "1本記録しました。"
  end

  # GET: 日付指定。該当ログが既にあれば edit へ。未記録なら行は作らない（@log は新規 or 非永続のまま表示）
  def new
    smoked_on = parse_smoked_on_query
    if smoked_on.nil? && params.key?(:smoked_on) && params[:smoked_on].present?
      redirect_to new_user_smoking_log_path, alert: "日付の形式が正しくありません。"
      return
    end
    smoked_on ||= Time.zone.today

    if smoked_on > Time.zone.today
      @log = current_user.user_smoking_logs.new(smoked_on: smoked_on, smoking_count: 0)
      @log.errors.add(:smoked_on, "に未来の日付は指定できません")
      return render :new, status: :unprocessable_entity
    end

    existing = current_user.user_smoking_logs.find_by(smoked_on: smoked_on)
    if existing
      redirect_to edit_user_smoking_log_path(existing)
    else
      @log = current_user.user_smoking_logs.new(smoked_on: smoked_on, smoking_count: 0)
    end
  end

  def create
    attrs = user_smoking_log_input_params
    smoked_on = attrs[:smoked_on]
    count_result = attrs[:smoking_count]

    if smoked_on.nil?
      @log = current_user.user_smoking_logs.new
      @log.errors.add(:base, "日付を指定してください。")
      return render :new, status: :unprocessable_entity
    end

    @log = current_user.user_smoking_logs.find_or_initialize_by(smoked_on: smoked_on)

    if count_result == :invalid
      prepare_log_after_invalid_count!
      return render @log.new_record? ? :new : :edit, status: :unprocessable_entity
    end

    if count_result == :blank
      assign_for_create_or_upsert!(@log, smoking_count: nil)
    else
      assign_for_create_or_upsert!(@log, smoking_count: count_result)
    end

    begin
      try_save_upsert_from_create!
    rescue ActiveRecord::RecordNotUnique
      @log = current_user.user_smoking_logs.find_by!(smoked_on: smoked_on)
      assign_smoking_count_after_race!(@log, count_result)
      if @log.save
        redirect_after_save!
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def edit
    @log = current_user.user_smoking_logs.find(params[:id])
  end

  def update
    @log = current_user.user_smoking_logs.find(params[:id])
    p = safe_update_param_hash
    count_result = parse_smoking_count_input(p[:smoking_count])

    if count_result == :invalid
      @log.errors.add(:smoking_count, :not_a_number)
      return render :edit, status: :unprocessable_entity
    end

    if count_result == :blank
      @log.assign_attributes(smoking_count: nil)
    else
      @log.assign_attributes(smoking_count: count_result)
    end

    if @log.save
      redirect_to edit_user_smoking_log_path(@log), notice: "本数を保存しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def prepare_log_after_invalid_count!
    @log.apply_snapshot_from_user_setting(current_user.user_setting) if @log.new_record?
    @log.errors.add(:smoking_count, :not_a_number)
  end

  def assign_smoking_count_after_race!(log, count_result)
    if count_result == :blank
      log.assign_attributes(smoking_count: nil)
    else
      log.assign_attributes(smoking_count: count_result)
    end
  end

  def try_save_upsert_from_create!
    if @log.save
      return redirect_to edit_user_smoking_log_path(@log), notice: "本数を保存しました。"
    end

    return render @log.new_record? ? :new : :edit, status: :unprocessable_entity
  end

  def redirect_after_save!
    redirect_to edit_user_smoking_log_path(@log), notice: "本数を保存しました。"
  end

  def assign_for_create_or_upsert!(log, smoking_count:)
    if log.new_record?
      log.assign_attributes(smoking_count: smoking_count)
      log.apply_snapshot_from_user_setting(current_user.user_setting)
    else
      log.assign_attributes(smoking_count: smoking_count)
    end
  end

  def parse_smoked_on_query
    raw = params[:smoked_on].presence
    return nil if raw.blank?
    parse_date_param(raw)
  end

  def user_smoking_log_input_params
    p = params.require(:user_smoking_log).permit(:smoked_on, :smoking_count)
    {
      smoked_on: parse_date_param(p[:smoked_on]),
      smoking_count: parse_smoking_count_input(p[:smoking_count])
    }
  rescue ActionController::ParameterMissing
    { smoked_on: nil, smoking_count: :blank }
  end

  # @return [Integer, :blank, :invalid]  空欄 → :blank, 数値化不可 (abc, 1.2 等) → :invalid
  def parse_smoking_count_input(raw)
    return :blank if raw.nil? || (raw.is_a?(String) && raw.strip.empty?)

    n = Integer(raw, exception: false)
    return :invalid if n.nil?

    n
  end

  def parse_date_param(value)
    return nil if value.blank?
    return value if value.is_a?(Date)
    return value.to_date if value.is_a?(Time) || value.is_a?(DateTime) || value.is_a?(ActiveSupport::TimeWithZone)
    Date.parse(value.to_s)
  rescue ArgumentError, TypeError
    nil
  end

  def safe_update_param_hash
    params.require(:user_smoking_log).permit(:smoking_count)
  end
end
