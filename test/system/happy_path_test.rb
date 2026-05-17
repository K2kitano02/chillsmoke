# frozen_string_literal: true

require "application_system_test_case"

class HappyPathTest < ApplicationSystemTestCase
  test "registration, setting, smoking log, wishlist purchase" do
    email = "happy_path_#{SecureRandom.hex(4)}@example.test"

    visit new_user_registration_path
    fill_in "名前", with: "Happy Path"
    fill_in "メールアドレス", with: email
    fill_in "パスワード", with: "password123"
    fill_in "パスワード（確認）", with: "password123"
    click_on "登録する"

    assert_text "初期設定"
    fill_in "1日の目標本数", with: 5
    fill_in "減煙前の1日あたりの本数（基準）", with: 20
    fill_in "1箱の価格（円）", with: 500
    fill_in "1箱あたりの本数", with: 20
    click_on "保存する"

    assert_text "ダッシュボード"
    click_on "＋1で記録"
    assert_text "1本記録しました。"
    assert_text "今日の本数"
    assert_text "1本"

    visit new_user_smoking_log_path(smoked_on: (Time.zone.today - 1.day).to_s)
    fill_in "本数", with: 0
    click_on "保存"
    assert_text "本数を保存しました。"

    click_on "ダッシュボードに戻る"
    assert_text "使用可能"
    assert_text "500円"

    click_on "ウィッシュリスト"
    click_on "新規登録"
    fill_in "名前", with: "テストイヤホン"
    fill_in "価格", with: 250
    fill_in "メモ", with: "ハッピーパス"
    click_on "登録する"

    click_on "購入する"

    assert_text "購入しました。"
    assert_text "購入済み"
    assert_text "購入履歴"
    assert_text "250円"
  end
end
