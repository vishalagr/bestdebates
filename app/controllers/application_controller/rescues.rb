class ApplicationController < ActionController::Base
  # Checks whether the app (bestdebates) is pubilc i.e., is running in production or staging mode
  def self.public_app?
    return true
    %W/production staging/.include?(RAILS_ENV)
  end
  
  if public_app? # exceptions catch only for 'public' apps
    rescue_from ActionController::RoutingError,  :with => :route_not_found
    rescue_from ActionController::UnknownAction, :with => :unknown_action
  end
  
  protected

  # ActionController::RoutingError
  def route_not_found
    static_404_page
  end
  
  # ActionController::UnknownAction
  def unknown_action
    static_404_page
  end
  
  # show 404 page if debate is not found
  def debate_not_found
    static_404_page
  end
  
  # show 404 page if argument is not found
  def argument_not_found
    static_404_page
  end
  
  # HTTP 404 page
  def static_404_page
    render :file => RAILS_ROOT+'/public/404.html', :status => :not_found
  end
end
