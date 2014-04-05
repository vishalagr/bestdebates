# used in deploy.rb too
REQUIRED_CONFIG_FILES = ['config/database.yml']

root_path = defined?(Rails) ? Rails.root : "#{File.dirname(__FILE__)}/../.."
REQUIRED_CONFIG_FILES.each do |f|
  raise Exception, "config file #{f} missed" unless File.exist? File.join(root_path, f)
end