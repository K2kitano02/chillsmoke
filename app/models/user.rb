class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true

  has_one :user_setting, dependent: :destroy
  has_many :user_smoking_logs, dependent: :destroy

  # 当日ログの表示用（行がなければ未保存の 0 本。GET 相当では create されない）
  def today_smoking_log_for_display
    SmokingLog::Today.for_display(self)
  end

  # 当日ログの取得または新規作成（+1 / 反映 / 本数保存などの「保存操作」専用）
  def find_or_create_today_smoking_log!
    SmokingLog::Today.find_or_create_persisted!(self)
  end
end
