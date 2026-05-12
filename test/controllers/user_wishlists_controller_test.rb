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

  test "一覧から詳細画面へ進める" do
    sign_in users(:one)
    wishlist = user_wishlists(:watch)

    get user_wishlists_url

    assert_response :success
    assert_select "a[href=?]", user_wishlist_path(wishlist), text: "腕時計"
  end

  test "show はログインユーザーのウィッシュリスト詳細を表示する" do
    sign_in users(:one)

    get user_wishlist_url(user_wishlists(:watch))

    assert_response :success
    assert_select "h1", text: "腕時計"
    assert_match(/30,000円/, response.body)
    assert_match(/仕事用/, response.body)
    assert_match(/未購入/, response.body)
    assert_select "button", text: "購入する"
    assert_select "a[href=?]", user_wishlists_path, text: "一覧へ戻る"
  end

  test "show は購入済みなら購入ボタンを表示しない" do
    sign_in users(:two)

    get user_wishlist_url(user_wishlists(:purchased_bag))

    assert_response :success
    assert_select "h1", text: "バッグ"
    assert_match(/購入済み/, response.body)
    assert_select "button", text: "購入する", count: 0
  end

  test "show は他ユーザーのウィッシュリストなら 404 を返す" do
    sign_in users(:one)

    get user_wishlist_url(user_wishlists(:purchased_bag))

    assert_response :not_found
  end
end
