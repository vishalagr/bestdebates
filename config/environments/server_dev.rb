# Settings specified here will take precedence over those in config/environment.rb
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false
#config.action_controller.perform_caching             = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

# ActionMailer settings for testing
config.action_mailer.delivery_method    = :sendmail #:test
config.action_mailer.perform_deliveries = true
config.action_mailer.default_charset    = "utf-8"
config.action_mailer.raise_delivery_errors = true

HOST_DOMAIN = 'dev.bestdebates.com'


ActionMailer::Base.delivery_method   = :sendmail
ActionMailer::Base.sendmail_settings = {
  :location => '/usr/sbin/sendmail', :arguments => "-i -t -O DeliveryMode='b'"
}
