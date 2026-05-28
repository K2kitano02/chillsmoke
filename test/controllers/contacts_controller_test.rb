require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "valid contact form sends email" do
    with_contact_mail_env do
      post contact_url, params: {
        contact_form: {
          name: "問い合わせ太郎",
          email: "user@example.com",
          message: "送信テストです。"
        }
      }
    end

    assert_redirected_to root_url
    assert_equal 1, ActionMailer::Base.deliveries.size

    mail = ActionMailer::Base.deliveries.last
    assert_equal [ "owner@example.com" ], mail.to
    assert_equal [ "contact@example.com" ], mail.from
    assert_equal [ "user@example.com" ], mail.reply_to
    assert_equal "ChillSmoke お問い合わせ", mail.subject
    assert_match(/問い合わせ太郎/, mail.text_part.body.decoded)
    assert_match(/送信テストです。/, mail.text_part.body.decoded)
  end

  test "invalid contact form does not send email" do
    with_contact_mail_env do
      post contact_url, params: {
        contact_form: {
          name: "",
          email: "invalid",
          message: ""
        }
      }
    end

    assert_response :success
    assert_equal 0, ActionMailer::Base.deliveries.size
    assert_select "#contact-title", text: "お問い合わせ"
    assert_match(/名前を入力してください/, response.body)
    assert_match(/メールアドレスは不正な値です/, response.body)
    assert_match(/お問い合わせ内容を入力してください/, response.body)
  end

  test "missing mail environment does not render 500" do
    with_env("CONTACT_MAIL_TO" => nil, "CONTACT_MAIL_FROM" => nil) do
      post contact_url, params: {
        contact_form: {
          name: "問い合わせ太郎",
          email: "user@example.com",
          message: "送信テストです。"
        }
      }
    end

    assert_response :success
    assert_equal 0, ActionMailer::Base.deliveries.size
    assert_match(/お問い合わせの送信に失敗しました/, response.body)
  end

  private

  def with_contact_mail_env(&block)
    with_env(
      "CONTACT_MAIL_TO" => "owner@example.com",
      "CONTACT_MAIL_FROM" => "ChillSmoke <contact@example.com>",
      &block
    )
  end

  def with_env(values)
    original = values.keys.to_h { |key| [ key, ENV[key] ] }
    values.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end
    yield
  ensure
    original.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end
  end
end
