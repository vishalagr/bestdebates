namespace :deploy do
  namespace :web do
  #  [:start, :stop, :cold].each do |t|
  #     desc "#{t} task is a no-op with mod_rails"
  #     task t, :roles => :app do ; end
  #   end

    # Overwrite the default method
    task :stop do
      run "cd #{current_path} && #{try_sudo} mongrel_rails cluster::stop"
    end

    task :start do
      run "cd #{current_path} && #{try_sudo} mongrel_rails cluster::start -C"
    end

    task :restart do
      run "cd #{current_path} && #{try_sudo} mongrel_rails cluster::restart"
    end
  end
end
