# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on. 
  # They can then be installed with "rake gems:install" on new installations.
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem 'ruby-openid', :lib => 'openid', :version => '>=2.0.4'
  #config.gem 'mongrel'
  config.gem 'thinking-sphinx', :version => '1.4.11'

  config.gem 'will_paginate', :source => "http://gemcutter.org"
  config.gem 'gravtastic',    :source => "http://gemcutter.org"
  config.gem 'sanitize',      :source => "http://gemcutter.org"
 # config.gem "jammit",        :source => "http://gemcutter.org"
  config.gem 'nokogiri',      :version => '~> 1.3.3'   # rgrove-sanitize require it
  config.gem 'chronic',       :version => '0.2.3'
  config.gem 'twitter_oauth', :source => "http://gemcutter.org"
  config.gem 'url_shortener', :source => "http://gemcutter.org"
  #config.gem "rubyist-aasm", :lib => "aasm", :source => "http://gems.github.com"
  config.gem 'aasm'
  #  config.gem 'facebooker',    :source => "http://gemcutter.org"
  config.gem 'daemons'
  config.gem 'mysql', :version => '2.7'

 # config.gem 'mongrel_cluster'
#  config.gem 'mongrel'
  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Uncomment to use default local time.
  config.time_zone = 'Pacific Time (US & Canada)'

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_knowlydge_session',
    :secret      => '4274cd7d6a226ce97ce13c5bc69879f9a0cafad683cbb824ae0ff09f663c0be6e16bbb1c57a8accc33b94df2c10b87de0a865afbb378852bac8004913f12b4a3'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  #	config.active_record.observers = :user_observer
  
  config.load_paths += %W( #{RAILS_ROOT}/app/sweepers #{RAILS_ROOT}/app/observers )
  #  config.cache_store = :file_store, File.join(Rails.root, "tmp/cache")
end
