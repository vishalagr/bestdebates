# This controller handles the login/logout function of the site.  
require 'openid'
class SessionsController < ApplicationController	
	# verify :xhr => true, :only => [:forgot_password] # TODO recheck
  skip_filter :featured_debates
	
  # New session -- Login page
  def new
    remember_prev_page!
   if !session[:invitation_code].blank?
    @user = User.new
    @user.use_invitation_code(find_invitation_code)
     flash[:notice] = "if you wish to response to an argument or debate you have to register, please register."
    # Group member signup
    @group = (params[:hash] ? Group.find_by_unique_hash(params[:hash]) : nil)
    @user.group_id = @group.id if @group
    end
    respond_to do |format|
      format.html
      format.js {render :partial => "login_tip"}
    end
  end

  # Create a new session -- login
  def create
    #    logout_keeping_session!
    full_logout
    
    if using_open_id?
      open_id_authentication
    else
      password_authentication
    end
    save_sponsor_user  
  end

  # Destroy a session -- logout
  def destroy
    full_logout(false)
    
    remember_prev_page! # must be after the session reset method call(in logout_killing_session!)
    flash[:notice] = "You have been logged out."
    #redirect_back_or_default(root_url)
    redirect_to(root_url)
  end
  
  private

  # Method used to logout of bestdebates as well as facebook (facebook connect)
  def full_logout(keeping_session=true)
    keeping_session ? logout_keeping_session! : logout_killing_session!
    fb_logout!
    kill_login_cookie!
  end

  # Authenticate given login and password in the database
  def password_authentication
    if user = User.authenticate(params[:login], params[:password])
      successful_login(user,params[:url])
    else
      failed_login(user, "Couldn't log you in as '#{params[:login]}'")
    end
  end
  
  # Authenticate using OpenID
  def open_id_authentication
    authenticate_with_open_id(params[:openid_url], :required => [:nickname, :email]) do |result, identity_url, registration|
      return failed_login(nil, result.message) unless result.successful?
      
      user = User.create_from_openid(identity_url, registration)
      user.new_record? ? failed_login(user) : successful_login(user)
    end
  end
  
  # Method in which a new Login is created and cookies are initialized
  def successful_login(user,url=nil)
    # Protects against session fixation attacks, causes request forgery
    # protection if user resubmits an earlier form using back
    # button. Uncomment if you understand the tradeoffs.
    # reset_session
    self.current_user = user
    new_cookie_flag = (params[:remember_me] == "1")
    handle_remember_cookie!(new_cookie_flag)

    #    self.return_to = params[:url] if params[:url] and !is_home_or_login_or_signup(params[:url])
    #    if params[:url] and not is_home_or_login_or_signup(params[:url])
    #      self.return_to = params[:url]
    #    else
    #      self.return_to = user.last_visited if user.last_visited and session[:return_to].blank?
    #    end    
    update_logins
    
    flash[:notice] = "Logged in successfully"
    if url.blank?
      redirect_back_or_default(root_url)
    else
      redirect_to url
    end
         
  end
  
  # Failed Login!
  # What to do for a failed login
  def failed_login(user, message=nil)
    flash.now[:error] = message if message
    
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"

    @login_user  = user
    @login       = params[:login]
    @remember_me = params[:remember_me]
   
      render :action => 'new'   
  end

  # Logout of facebook
  def fb_logout!
    clear_facebook_session_information
    clear_fb_cookies!
  end
  #  def is_home_or_login_or_signup(url)
  #    a = url.split('//')[-1].split('/')
  #    return true if a.size < 2 || (a[1] == "login" or a[1] == "signup") || (a[2] == "new" and (a[1] == "session" or a[1] == "users" ))
  #    return false
  #  end
end
