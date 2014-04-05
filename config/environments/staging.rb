# Settings specified here will take precedence over those in config/environment.rb
config.cache_classes = true
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

HOST_DOMAIN = 'staging.bestdebates.com'

# ActionMailer settings
#config.action_mailer.delivery_method = :sendmail
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_charset = "utf-8"

#ActionMailer::Base.delivery_method   = :sendmail
#ActionMailer::Base.sendmail_settings = {
#  :location => '/usr/sbin/sendmail', :arguments => "-i -t -O DeliveryMode='b'"
#}

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :tls => true,
  :address => "smtp.gmail.com",
  :port => "587",
  :domain => "gmail.com",
  :authentication => :plain,
  :user_name => "info.bestdebates",
  :password => "bestdebates"
}