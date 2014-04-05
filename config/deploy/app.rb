namespace :app do
  desc 'Refresh the assets'
  task :redeploy_notify, :roles => :app do
    run "cd #{current_path} && rake app:redeploy_notify RAILS_ENV=#{rails_env}"
  end
end