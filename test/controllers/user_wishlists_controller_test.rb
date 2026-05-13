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

  test "一覧から新規登録画面へ進める" do
    sign_in users(:one)

    get user_wishlists_url

    assert_response :success
    assert_select "a[href=?]", new_user_wishlist_path, text: "新規登録"
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

  test "new はウィッシュリスト登録フォームを表示する" do
    sign_in users(:one)

    get new_user_wishlist_url

    assert_response :success
    assert_select "h1", text: "ウィッシュリスト登録"
    assert_select "form[action=?]", user_wishlists_path
    assert_select "input[name=?]", "user_wishlist[name]"
    assert_select "input[name=?]", "user_wishlist[price]"
    assert_select "textarea[name=?]", "user_wishlist[memo]"
  end

  test "create はログインユーザーに紐づくウィッシュリストを作成して詳細へ進む" do
    sign_in users(:one)

    assert_difference -> { users(:one).user_wishlists.count }, 1 do
      post user_wishlists_url, params: {
        user_wishlist: {
          name: "イヤホン",
          price: 15_000,
          memo: "通勤用",
          is_purchased: "1",
          user_id: users(:two).id
        }
      }
    end

    wishlist = users(:one).user_wishlists.order(:created_at).last
    assert_redirected_to user_wishlist_url(wishlist)
    assert_equal "イヤホン", wishlist.name
    assert_equal 15_000, wishlist.price
    assert_equal "通勤用", wishlist.memo
    assert_not wishlist.is_purchased
    assert_equal users(:one), wishlist.user
  end

  test "create はバリデーションエラーなら 422 で new を再表示する" do
    sign_in users(:one)

    assert_no_difference -> { UserWishlist.count } do
      post user_wishlists_url, params: {
        user_wishlist: {
          name: "",
          price: 0,
          memo: "不正"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "h1", text: "ウィッシュリスト登録"
    assert_select ".bg-red-50"
  end
end
