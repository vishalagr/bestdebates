class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include ExceptionLoggable if %W/production staging/.include?(RAILS_ENV) # exceptions catching only for the 'public' apps
  
#  before_filter :staging_mode_authenticate, :if => lambda{|e| Rails.env == 'staging'} # suspend: fb can't handle it
 # before_filter { Jammit.packager.precache_all } if Rails.env == 'development'
  before_filter :featured_debates,:host_url, :support_pages,:featured_debates_all_pages
  #before_filter { Jammit.packager.precache_all } if %W/production staging/.include?(RAILS_ENV)
  concerned_with :auth, :rescues, :finds

  helper :all # include all helpers, all the time
  helper_method :show_featured_debates?
  helper_method :show_featured_debates_all_pages?
  helper_method :show_start_box?
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  
  # TODO uncomment + recheck controllers
  #protect_from_forgery # :secret => '302f7f22ca0671eb31db6389d2cb839b'
  
  filter_parameter_logging :password
  
  protected

  # Sets title the of the debate or argument to be displayed in HTML title tag
  def set_title
    if @debate || @argument
      @title = (@argument || @debate).title #+ ' | BestDebates.com'
    end    
  end

  # Checks whether the request corresponds to login or signup pages
  def login_or_signup?
    controller_name =~ /users|sessions/ and action_name =~ /new|create/
  end

   def host_url
    if %W/production staging/.include?(RAILS_ENV)
     @host = request.host
    else
      @host = request.host_with_port
    end
  end
  # Checks whether featured debates be shown for the particular request
  # Featured debates are displayed in the right side box in all pages except
  # when the page in login_or_signup? page or the user is not admin
  def show_featured_debates?
    !login_or_signup? and !admin_user? 
  end
   
  def show_start_box?
		!login_or_signup?
  end
	 
  def show_featured_debates_all_pages?
   true# !admin_user? 
  end  
  # ActionController::Base.helpers
  # for newer Rails
  def view_helpers
    @template
  end
end
