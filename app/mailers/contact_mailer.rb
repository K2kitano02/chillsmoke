class ContactMailer < ApplicationMailer
  class ConfigurationError < StandardError; end

  def contact_email(contact_form)
    @contact_form = contact_form

    mail(
      to: required_env("CONTACT_MAIL_TO"),
      from: required_env("CONTACT_MAIL_FROM"),
      reply_to: @contact_form.email,
      subject: "ChillSmoke お問い合わせ"
    )
  end

  private

  def required_env(name)
    ENV[name].presence || raise(ConfigurationError, "#{name} is not configured")
  end
end
