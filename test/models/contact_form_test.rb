require "test_helper"

class ContactFormTest < ActiveSupport::TestCase
  test "名前、メールアドレス、内容があれば有効" do
    form = ContactForm.new(name: "山田 太郎", email: "taro@example.com", message: "問い合わせ内容です。")

    assert form.valid?
  end

  test "必須項目が空なら無効" do
    form = ContactForm.new

    assert_not form.valid?
    assert form.errors.of_kind?(:name, :blank)
    assert form.errors.of_kind?(:email, :blank)
    assert form.errors.of_kind?(:message, :blank)
  end

  test "メールアドレス形式でなければ無効" do
    form = ContactForm.new(name: "山田 太郎", email: "invalid-email", message: "問い合わせ内容です。")

    assert_not form.valid?
    assert form.errors.of_kind?(:email, :invalid)
  end
end
