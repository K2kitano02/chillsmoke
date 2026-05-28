class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("DEVISE_MAILER_FROM", "ChillSmoke <no-reply@chillsmoke.example>")
  layout "mailer"
end
