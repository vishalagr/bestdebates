# #############################################################
# # Git
# #############################################################
set :scm, 'git'
#set :deploy_via, :copy # Have to do the :copy method with Github for some reason
#set :copy_exclude, [".git", ".svn"]
set :deploy_via, :remote_cache
set :repository,  'git@bestdebates.unfuddle.com:bestdebates/bestbebates.git'
set :git_shallow_clone, 1
set :git_enable_submodules, true
# <--GIT END

default_run_options[:pty]   = true
ssh_options[:forward_agent] = true
ssh_options[:port] = 22