require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  test "未ログインでも問い合わせを送信できる" do
    assert_emails 1 do
      post contact_url, params: {
        contact_form: {
          name: "山田 太郎",
          email: "taro@example.com",
          message: "問い合わせ内容です。"
        }
      }
    end

    assert_redirected_to root_url
    assert_equal "お問い合わせを送信しました。", flash[:notice]

    mail = ActionMailer::Base.deliveries.last
    assert_equal [ "contact@example.com" ], mail.to
    assert_equal "ChillSmoke お問い合わせ", mail.subject
  end

  test "入力エラー時は送信せずHomeを再表示する" do
    assert_no_emails do
      post contact_url, params: {
        contact_form: {
          name: "",
          email: "invalid-email",
          message: ""
        }
      }
    end

    assert_response :success
    assert_select "#contact-title", text: "お問い合わせ"
    assert_match(/名前を入力してください/, response.body)
    assert_match(/メールアドレスの形式が正しくありません/, response.body)
    assert_match(/内容を入力してください/, response.body)
  end
end
