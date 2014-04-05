# http://madebymany.co.uk/tutorial-for-restful_authentication-on-rails-with-facebook-connect-in-15-minutes-00523
class Facebook::MyFacebookController < ApplicationController

  def index
    render :text => 'Welcome to Best Debates', :layout => 'application'
  end
end
