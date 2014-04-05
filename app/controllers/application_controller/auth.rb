class ApplicationController < ActionController::Base
  before_filter      :set_facebook_session # FB auth
  filter_parameter_logging :fb_sig_friends # To prevent a violation of Facebook Terms of Service while reducing log bloat

  helper_method :admin_user?
  helper_method :can_edit_argument?, :can_create_argument?, :can_rate_argument?
  helper_method :can_edit_debate?
  
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie, :login_from_fb
  before_filter :update_logins
  
  protected
  
  # Checks whether +current_user+ is an administrator
  def admin_user?
    logged_in? and current_user.admin?
  end
  
  # Checks whether the +current_user+ can modify the debate +debate+
  def can_edit_debate?(debate)
    return false unless logged_in?
    
    debate.can_be_modified_by?(current_user)
  end
  
  # Checks whether the +current_user+ can modify the argument +argument+
  def can_edit_argument?(argument=@argument)
    return false unless logged_in?

    admin_user? or argument.can_be_modified_by?(current_user)
  end
  
  # Checks whether the +current_user+ can modify the resource +resource+
  def can_edit_resource?(resource)
    case resource.class.to_s
    when 'Debate'
      can_edit_debate?(resource)
    when 'Argument'
      can_edit_argument?(resource)
    end
  end

  # Checks whether the +current_user+ can create the +argument_or_debate+
  def can_create_argument?(argument_or_debate)
    debate = argument_or_debate.is_a?(Debate) ? argument_or_debate : argument_or_debate.debate
    
    debate.public? or admin_user? or debate.owner?(current_user) or 
      # has been the user join the debate?
      !!debate.joined_users.find_by_user_id(current_user).try(:is_writable?)
  end
  
  # Checks whether the +current_user+ can rate the argument +argument+
  def can_rate_argument?(argument=@argument)
     # argument owner can't rate
    logged_in? and !argument.owner?(current_user)
  end
  
  # before_filter to restrict unauthorized users from viewing the debate +debate+
  def debate_show_permission_check(debate=@debate)
    unless debate.public? or debate.can_be_read_by?(current_user)
      flash[:error] = 'You have\'nt permission to read the debate'
      redirect_to debates_url
    end
  end
  
  # before_filter to restrict unauthorized users from editing the argument
  def argument_edit_permission_check
    @argument or find_argument

    return true if admin_user?

    if !@argument.owner?(current_user) or @argument.immutable?
      flash_notice = 'Either the argument is immutable or you don\'t have permissions to edit it'
      #return access_denied(debates_path)

      respond_to do |format|
        format.html {flash[:error] = flash_notice; redirect_to @argument}
        format.js do
          render(:update){|page| flash.now[:error] = flash_notice; page.reload_flashes!}
        end
      end
    end

  end

  # before_filter to restrict access to only the administrator
  def admin_required    
    admin_user? || access_denied(debates_path)
  end
  
  # If a non-logged_in user tries to access a method which is only for 
  # logged_in users, the user is presented with a browser popup for 
  # credentials
  def access_denied(redirect_url=new_session_path)  
    respond_to do |format|
      format.html do
        store_location
        redirect_to redirect_url
      end
      format.any do
        request_http_basic_authentication 'Web Password'
      end
    end
  end
  
  # before_filter to update logins for every action
  def update_logins
    unless cookies[Login::COOKIES_IDENTIFIER] && login = Login.find_by_loginid(cookies[Login::COOKIES_IDENTIFIER])
      login = if logged_in?
        current_user.logins.create_from_session_id!(session.session_id)
      else
        Login.create_from_session_id!(session.session_id, :name => request.remote_ip)
      end
    end
    
    cookies[Login::COOKIES_IDENTIFIER] ||= login.loginid.to_s
    
    login.visit!
  end
  
  # ...
  # Staging mode authentication
  def staging_mode_authenticate(&block)
    authenticate_or_request_with_http_basic('Staging Area') do |username, password|
      username == 'staging' && Digest::MD5.hexdigest(password) == 'a6661db54db05f5fa04b28dbed17b52e'
    end
  end
  
  # before_filter to check whether any invitation_code is supplied through url
  # i.e., if the user has clicked on the invitation link received through email
  # if such invitation_code is present and valid, then the +current_user+ is added
  # to the list of <tt>joined_users</tt> of the debate
  def invitation_code_check
    return unless invitation_code = get_invitation_code
    
    if invitation_code.blank? or !(code = Code.find_by_unique_hash(invitation_code))
      flash[:error] = 'Invitation code is not found!'
      redirect_to(root_url) and return
    end
    
    resource = code.invitation.resource
    
    if code.invitation.user	    
	   self.current_user = code.invitation.user
     end

    if logged_in?	   
      # make current_user a member of @debate
      code.invitation.connect!(current_user)
      session[:invitation_code] = nil # unset
      flash[:notice] = "You successfully join the #{resource.class.to_s.downcase}"
      redirect_to resource
    else
	    puts "no"
      session[:invitation_code] = invitation_code
      store_location
      #redirect_to signup_url
    end
  end
  
  # before_filter to check whether any invite_link is supplied through url
  # i.e., if the user has clicked on the invite link 
  # if such invite link is present and valid, then the +current_user+ is added
  # to the list of <tt>joined_users</tt> of the debate
  def invite_link_check
    return unless unique_code = get_unique_code
    
    if unique_code.blank? or !(invite_link = InviteLink.find_by_unique_id(unique_code))
      flash[:error] = 'Invite link is not found!'
      redirect_to(root_url) and return
    end
    
    resource = invite_link.resource

    if logged_in?
      # make current_user a member of @debate
      invite_link.connect!(current_user)
      session[:unique_code] = nil # unset
      flash[:notice] = "You successfully joined the #{resource.class.to_s.downcase}"
      redirect_to resource
    else
      session[:unique_code] = unique_code
      store_location
      flash[:notice] = "Please login/signup to join the #{resource.class.to_s.downcase}"
      redirect_to signup_url
    end
  end

  # Associate users to sponsors
  def save_sponsor_user
    return unless params[:sponsor_allow]

    if (code = session[:unique_code]) and (invite_link = InviteLink.find_by_unique_id(code))
      SponsorUser.save_org_user(invite_link.user_id, @user.id)
    elsif (code = session[:invitation_code]) and (inv_code = Code.find_by_unique_hash(code))
      SponsorUser.save_org_user(inv_code.invitation.invitor_id, @user.id)
    end
  end
end
