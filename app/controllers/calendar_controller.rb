# frozen_string_literal: true

# ISSUE-40: 月カレンダー。GET のみ・表示のためだけに user_smoking_logs を読む（行は作成しない）。
class CalendarController < ApplicationController
  def index
    @start_date = parse_calendar_anchor_date # simple_calendar と同じ基準月
    date_range =
      @start_date.beginning_of_month.beginning_of_week..
        @start_date.end_of_month.end_of_week
    @logs = current_user.user_smoking_logs.where(smoked_on: date_range)
  end

  private

  def parse_calendar_anchor_date
    raw = params[:start_date].presence || Time.zone.today.iso8601
    raw.to_date
  rescue ArgumentError, TypeError
    Time.zone.today.to_date
  end
end
