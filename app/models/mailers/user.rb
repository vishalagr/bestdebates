class Mailers::User < Mailers::BaseMailer
  # signup greetings. after activation
  def signup_notification(user)
    setup_email(user)
    @subject += 'Your account has been activated!'
    content_type "text/html"
  end

  # activation link. after create
  def activation(user)
    setup_email(user)
    @subject += "Please activate your new account #{user.login}"
    content_type 'text/html'
  end
  
	def password_reset(user)
		setup_email(user)
		@subject += 'Your password has been reset'
    content_type 'text/html'
	end
end
