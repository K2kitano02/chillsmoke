# frozen_string_literal: true

class ScheduleReflection::Today
  Result = Data.define(:log, :reflected_count)

  class << self
    def call(user)
      today = Time.zone.today

      UserSmokingLog.transaction do
        log = SmokingLog::Today.find_or_create_persisted!(user)
        reflected_count = reflect_schedules!(user, log, today)

        Result.new(log: log.reload, reflected_count: reflected_count)
      end
    end

    private

    def reflect_schedules!(user, log, today)
      reflected_count = 0

      log.with_lock do
        unreflected_active_schedules(user, today).each do |schedule|
          next unless create_reflection_once(schedule, today)

          log.smoking_count += 1
          reflected_count += 1
        end

        log.save! if reflected_count.positive?
      end

      reflected_count
    end

    def unreflected_active_schedules(user, today)
      user.user_schedules
          .where(is_active: true)
          .where.not(id: UserScheduleReflection.where(reflected_on: today).select(:user_schedule_id))
          .order(:scheduled_smoking_minutes, :id)
    end

    def create_reflection_once(schedule, today)
      UserScheduleReflection.transaction(requires_new: true) do
        schedule.user_schedule_reflections.create!(reflected_on: today)
      end
      true
    rescue ActiveRecord::RecordNotUnique
      false
    rescue ActiveRecord::RecordInvalid => e
      raise e unless e.record.errors.of_kind?(:reflected_on, :taken)

      false
    end
  end
end
