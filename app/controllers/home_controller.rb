class HomeController < ApplicationController
  # Home page
  def index
    respond_to do |format|
      format.html
      format.xml
    end
  end

  def contact
    
  end

  def addon
    @argument = Argument.new
    @argument.debate_id = 0;
    render :layout => "firefox_layout"
  end
  
  def firefox
    render :layout => false  
  end
  
  def ff_feedback_page
  end

  def ff_welcome_page
  end
  
#Automatic login for firefox addon 
  def firefox_login
    if user = User.authenticate(params[:login], params[:pass])
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie!(new_cookie_flag)
      update_logins
      flash[:notice] = "Logged in successfully"
      render :text => true
    else
      flash.now[:error] = "Couldn't log you in as '#{params[:login]}'"
      
      logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
      
      @login_user  = user
      @login       = params[:login]
      @remember_me = params[:remember_me]
      full_logout(false)
      render :text => false
    end 
  end

  def firefox_logout
    full_logout(false)
    redirect_to(ff_welcome_page_url)
  end
  
  #to check specified name is already logged in the system for firefox addon
  def logged_user  
    render :text => logged_in?  ? current_user.login == params[:login] : false
  end
  
  private
  
  def full_logout(keeping_session=true)
    keeping_session ? logout_keeping_session! : logout_killing_session!    
    kill_login_cookie!
  end
  
  
  
end
