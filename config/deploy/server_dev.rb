set :user,     ACCESS[:server_dev_user]
set :password, ACCESS[:server_dev_password]

# git
set :branch, "master"

set :rails_env,     'server_dev'
set :mongrel_port,  '40630'
set :mongrel_nodes, '1'

set :deploy_to,     "/var/www/dev.bestdebates.com"
set :keep_releases, 3