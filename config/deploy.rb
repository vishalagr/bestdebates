# FAQ http://wiki.capify.org/article/Special:Allpages
set :stages,      %w(server_dev staging production)
set :default_stage, 'staging'
require 'capistrano/ext/multistage'
require 'config/initializers/config_files_check'

ACCESS = YAML.load_file(File.dirname(__FILE__) + '/deploy/access.yml')

base_path = File.dirname(__FILE__)
load File.join(base_path, 'deploy/scm_config')
load File.join(base_path, 'deploy/app')
load File.join(base_path, 'deploy/deploy_web')

set :application, "debate"
set :domain,      "bestdebates.com"
set :group_writable, false
set :use_sudo,       false

# extra_capistrano_tasks
set :use_mod_rails, false
set :app_symlinks,  ['public/system', *REQUIRED_CONFIG_FILES]
require File.dirname(__FILE__) + '/deploy/extra_capistrano_tasks'

set :chmod755, "app config db lib public vendor script script/* public/disp*" 

### roles (servers) #################################
set :repository, "git@bestdebates.unfuddle.com:bestdebates/bestbebates.git"
server "184.168.114.75", :app, :web, :db, :primary => true, :port=> "13222",:ssh=>"bestdebates@teapot.friesen.org"
set :ssh_options, { :forward_agent => true }

#after "deploy:update_code", 'install:gems'
#after "deploy:update_code", 'assets:refresh'
#after "deploy:update_code", 'app:redeploy_notify'

namespace :assets do
  desc 'Refresh the assets'
  task :refresh, :roles => :app do
    p current_path
 #   run "ruby -i \"Dir.glob(File.join('#{current_path}', 'vendor/gems/jammit*/bin/jammit'))\" " do |channel, stream, data|
#      p channel
   #   p stream
  #    p data
 #   end
#    run jammit_exec
  end
end


