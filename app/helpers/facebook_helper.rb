module FacebookHelper
  def fb_user?
    logged_in? and current_user.fb_user?
  end

  def fb_app_perm?
    logged_in? and current_user.fb_user? and (current_user.fb_session.user.has_permissions? ['create_event', 'publish_stream'] if current_user.fb_session.user)
  end
  
  def fb_connect_with_facebook_button
    fb_login_button "window.location = '#{link_accounts_path}'", :size => 'large', :background => 'light', :length => 'long'
  end
  
  def fb_link_to_logout(name)
#    link_to image_tag('http://static.ak.fbcdn.net/images/fbconnect/logout-buttons/logout_small.gif'), logout_path, :title => 'Sign Out', :onclick => "FB.Connect.logoutAndRedirect('#{logout_path}')"
#    fb_logout_link  image_tag('http://static.ak.fbcdn.net/images/fbconnect/logout-buttons/logout_medium.gif'), logout_path
#    fb_login_button image_tag('http://static.ak.fbcdn.net/images/fbconnect/logout-buttons/logout_medium.gif'), logout_path, :autologoutlink => true, :size => 'small'
    fb_logout_link(name, logout_path)
  end

  def fb_facebook_event_link(evid, name=nil)
    link_to((name || "http://www.facebook.com/event.php?eid=#{evid}"), "http://www.facebook.com/event.php?eid=#{evid}") if evid
  end
  
  def fb_facebook_share_link(url, title, name='Share')
    link_to name, "http://www.facebook.com/sharer.php?u=#{url}&t=#{title}"
  end

  def render_connect_with_facebook
    fb_connect_with_facebook_button unless fb_user?
	end

  def fd_name_tag(user)
    fb_name(user, :capitalize => true, :useyou => false)
  end

#  def ensure_has_all_required_permissions?
#    ensure_application_is_installed_by_facebook_user and ensure_has_create_event and ensure_has_publish_stream
#  end

#  def ensure_has_publish_stream
#    has_extended_permission?("publish_stream") || application_needs_permission("publish_stream")
#  end
end