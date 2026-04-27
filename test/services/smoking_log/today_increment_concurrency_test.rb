# frozen_string_literal: true

require "test_helper"

# スレッド並行時はコネクションごとにトランザクションが分かれるため、このファイルだけトランザクションテストを切る
class SmokingLog::TodayIncrementConcurrencyTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    @user = User.create!(
      email: "concurrent_inc_#{SecureRandom.hex(4)}@example.test",
      name: "Concurrent",
      password: "password123",
      password_confirmation: "password123"
    )
    @user.create_user_setting!(
      target_daily_cigarette_count: 5,
      baseline_daily_cigarette_count: 20,
      pack_price: 500,
      cigarettes_per_pack: 20,
      is_oni_mode: false
    )
  end

  teardown do
    @user&.destroy
  end

  test "parallel increment_persisted! from threads does not lose counts" do
    n = 20
    threads = n.times.map do
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          SmokingLog::Today.increment_persisted!(@user)
        end
      end
    end
    threads.each(&:join)

    log = @user.user_smoking_logs.find_by!(smoked_on: Time.zone.today)
    assert_equal n, log.smoking_count
  end
end
