require "test_helper"

class UserSettingsControllerTest < ActionDispatch::IntegrationTest
  test "未ログインで new へアクセスするとサインインへ飛ばされる" do
    get new_user_setting_url
    assert_redirected_to new_user_session_path
  end

  test "既存設定ユーザーの GET /user_setting/new が dashboard にリダイレクトされること" do
    sign_in users(:one)
    assert users(:one).user_setting.present?

    get new_user_setting_url
    assert_redirected_to dashboard_url
    assert_match(/すでに登録/, flash[:alert].to_s)
  end

  test "既存設定ユーザーの POST /user_setting でも新規作成されず dashboard にリダイレクトされること" do
    sign_in users(:one)
    assert_no_difference -> { UserSetting.count } do
      post user_setting_url, params: {
        user_setting: {
          target_daily_cigarette_count: 1,
          baseline_daily_cigarette_count: 99,
          pack_price: 100,
          cigarettes_per_pack: 20
        }
      }
    end
    assert_redirected_to dashboard_url
    assert_match(/すでに登録/, flash[:alert].to_s)
    # 既存設定は書き換わらない
    s = users(:one).reload.user_setting
    assert_equal 5, s.target_daily_cigarette_count
  end

  test "未設定ユーザーは new/create を通過できること" do
    user = users(:three)
    sign_in user
    assert_nil user.reload.user_setting

    get new_user_setting_url
    assert_response :success
    assert_select "h1", text: "初期設定"

    assert_difference -> { UserSetting.count }, 1 do
      post user_setting_url, params: {
        user_setting: {
          target_daily_cigarette_count: 5,
          baseline_daily_cigarette_count: 20,
          pack_price: 500,
          cigarettes_per_pack: 20,
          is_oni_mode: "0"
        }
      }
    end
    assert_redirected_to dashboard_url
    follow_redirect!
    assert_match(/初期設定を保存/, flash[:notice].to_s)

    s = user.reload.user_setting
    assert_equal 5, s.target_daily_cigarette_count
    assert_equal 20, s.baseline_daily_cigarette_count
  end

  test "create がバリデーションエラーなら 422 で new を再表示" do
    sign_in users(:three)
    assert_no_difference -> { UserSetting.count } do
      post user_setting_url, params: {
        user_setting: {
          target_daily_cigarette_count: 20,
          baseline_daily_cigarette_count: 5,
          pack_price: 500,
          cigarettes_per_pack: 20
        }
      }
    end
    assert_response :unprocessable_entity
  end
end
