class HomeController < ApplicationController
  # アプリの説明・オンボーディング。未ログインでも閲覧可（上記アクション以外は要ログイン）
  skip_before_action :authenticate_user!, only: :index

  def index
  end
end
