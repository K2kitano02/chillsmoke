class ContactsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :ensure_user_setting_exists

  def create
    @contact_form = ContactForm.new(contact_params)

    return render_contact_form unless @contact_form.valid?

    ContactMailer.contact_email(@contact_form).deliver_now
    redirect_to root_path, notice: "お問い合わせを送信しました。"
  rescue StandardError => e
    Rails.logger.warn("Contact email delivery failed: #{e.class}: #{e.message}")
    @contact_form ||= ContactForm.new(contact_params)
    @contact_form.errors.add(:base, "お問い合わせの送信に失敗しました。時間をおいて再度お試しいただくか、Xからご連絡ください。")
    render_contact_form
  end

  private

  def contact_params
    params.fetch(:contact_form, {}).permit(:name, :email, :message)
  end

  def render_contact_form
    @open_modal = "contact"
    render "home/index"
  end
end
