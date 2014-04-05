DEVELOPERS_EMAILS = ["kranthi.odesk@gmail.com"]#, Mark@KnowlYdge.com"]

LoggedExceptionsMailer.mailer_config.update( {
  :deliver     => true,
  :subject     => "[#{Rails.env.titleize}] BestDebates Exception",
  :recipients  => DEVELOPERS_EMAILS,
  :from        => '',
  :link        => "http://somewhere/logged_exceptions"
})

Mailers::App.to_emails = DEVELOPERS_EMAILS
