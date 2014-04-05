set :user,     ACCESS[:staging_user]
set :password, ACCESS[:staging_password]

# git
set :branch, "master"

set :rails_env,     'staging'
set :mongrel_port,  '4065'
set :mongrel_nodes, '1'

set :deploy_to, "/home/staging/apps/debate"
set :keep_releases, 2