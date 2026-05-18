class ContactsController < ApplicationController
  skip_before_action :authenticate_user!, only: :create
  skip_before_action :ensure_user_setting_exists, only: :create

  def create
    @contact_form = ContactForm.new(contact_form_params)

    if @contact_form.valid?
      ContactMailer.inquiry(@contact_form).deliver_now
      redirect_to root_path, notice: "お問い合わせを送信しました。"
    else
      @open_contact_modal = true
      render "home/index", status: :ok
    end
  end

  private

  def contact_form_params
    params.require(:contact_form).permit(:name, :email, :message)
  end
end
