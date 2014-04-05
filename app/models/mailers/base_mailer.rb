class Mailers::BaseMailer < ActionMailer::Base
  default_url_options.update :host => HOST_DOMAIN
  helper :application
  
  protected
  
  # Setup 'from', 'subject', 'sent_on', 'recipients'
  # - to be overridden later by other mailers
  def setup_email(user_or_email) #user or guest
    if user_or_email.is_a?(User)
      @recipients  = user_or_email.email.to_s
      @body[:user] = user_or_email # auto assign an user
    else
      @recipients  = "#{user_or_email}"
    end 
    
    @from        = "info@bestdebates.com"
    @subject     = "BestDebates.com: "
    @sent_on     = Time.now
  end
end
