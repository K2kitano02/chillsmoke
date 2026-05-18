require "test_helper"

class ContactMailerTest < ActionMailer::TestCase
  test "問い合わせメールに送信先、件名、返信先、本文を含める" do
    contact_form = ContactForm.new(
      name: "山田 太郎",
      email: "taro@example.com",
      message: "画面の表示について相談があります。"
    )

    mail = ContactMailer.inquiry(contact_form)

    assert_equal [ "contact@example.com" ], mail.to
    assert_equal [ "taro@example.com" ], mail.reply_to
    assert_equal "ChillSmoke お問い合わせ", mail.subject
    assert_match "山田 太郎", mail.body.encoded
    assert_match "taro@example.com", mail.body.encoded
    assert_match "画面の表示について相談があります。", mail.body.encoded
  end
end
