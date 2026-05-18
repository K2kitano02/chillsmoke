class ContactMailer < ApplicationMailer
  def inquiry(contact_form)
    @contact_form = contact_form

    mail(
      to: contact_mail_to,
      subject: "ChillSmoke お問い合わせ",
      reply_to: @contact_form.email
    )
  end

  private

  def contact_mail_to
    ENV.fetch("CONTACT_MAIL_TO") do
      raise "CONTACT_MAIL_TO is required" if Rails.env.production?

      "contact@example.com"
    end
  end
end
