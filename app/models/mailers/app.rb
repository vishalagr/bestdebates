class Mailers::App < Mailers::BaseMailer
  cattr_accessor :to_emails
  
  # Send an email after the app has been redeployed
  def redeploy
    setup_email @@to_emails
    @subject = "[#{Rails.env.titleize}] BestDebates redeployed (#{Time.now.to_s})"
    @body    = @subject
  end
end
