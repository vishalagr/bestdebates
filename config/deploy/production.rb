set :user,     ACCESS[:production_user]
set :password, ACCESS[:production_password]

# git
set :branch, "master"

set :rails_env,     'production'
set :mongrel_port,  '4064'
set :mongrel_nodes, '5'
set :port_number, "13222"
set :deploy_to, "/home/web/bestdebates.com/production/debate"
set :keep_releases, 10