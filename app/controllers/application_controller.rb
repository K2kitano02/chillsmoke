class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # Devise 用の sign_up / account_update に :name を通す（この before_action 未定義だと strong params に載らない）
  before_action :configure_permitted_parameters, if: :devise_controller?
  # 未ログインは全画面（Devise ・ Home#index 以外）で sign_in へ。Home#index はオンボーディング用に公開
  before_action :authenticate_user!, unless: :devise_controller?
  allow_browser versions: :modern

  # ログイン成功後: 本番のダッシュボード実装（TODO）に差し替え可能
  def after_sign_in_path_for(_resource)
    root_path
  end

  # ログアウト後: オンボーディング（root）へ戻る
  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
