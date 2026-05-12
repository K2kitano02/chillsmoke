# frozen_string_literal: true

require "test_helper"

class UserWishlistsControllerTest < ActionDispatch::IntegrationTest
  test "未ログインではウィッシュリスト一覧を開けない" do
    get user_wishlists_url

    assert_redirected_to new_user_session_url
  end

  test "UserSetting 未作成なら初期設定へリダイレクトされる" do
    sign_in users(:three)

    get user_wishlists_url

    assert_redirected_to new_user_setting_url
  end

  test "ログインユーザーのウィッシュリストだけを一覧表示する" do
    sign_in users(:one)

    get user_wishlists_url

    assert_response :success
    assert_select "h1", text: "ウィッシュリスト"
    assert_match(/腕時計/, response.body)
    assert_match(/30,000円/, response.body)
    assert_match(/仕事用/, response.body)
    assert_match(/未購入/, response.body)
    assert_no_match(/バッグ/, response.body)
    assert_no_match(/購入済みサンプル/, response.body)
  end

  test "ウィッシュリストがなければ空状態を表示する" do
    sign_in users(:one)
    users(:one).user_wishlists.destroy_all

    get user_wishlists_url

    assert_response :success
    assert_match(/まだウィッシュリストは登録されていません/, response.body)
  end

  test "一覧からダッシュボードへ戻れる" do
    sign_in users(:one)

    get user_wishlists_url

    assert_response :success
    assert_select "a[href=?]", dashboard_path, text: "ダッシュボードへ戻る"
  end
end
