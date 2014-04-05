# http://madebymany.co.uk/tutorial-for-restful_authentication-on-rails-with-facebook-connect-in-15-minutes-00523
# http://www.liverail.net/articles/2007/7/16/continuing-facebook-applications-with-ruby-on-rails
class User < ActiveRecord::Base
  attr_protected :fb_email_hash, :fb_session_key, :fb_user_id

  class << self
    # find the user in the database, first by the facebook user id and if that fails through the email hash
    def find_by_fb_user(fb_user)
      User.find_by_fb_user_id(fb_user.uid) || User.find_by_fb_email_hash(fb_user.email_hashes)
    end

    # Finds the user given +facebook_session+
    def find_by_fb_session(facebook_session)
      returning User.find_by_fb_user(facebook_session.user) do |user|
        user.store_facebook_session(facebook_session.session_key) unless user.nil? or facebook_session.nil?
      end
    end

    # Returns login name ( 'facebook_' appended to the user id ) of the given user +fb_user+
    def fb_login_for(fb_user)
      "facebook_#{fb_user.uid}"
    end

    #Take the data returned from facebook and create a new user from it.
    #We don't get the email from Facebook and because a facebooker can only login through Connect we just generate a unique login name for them.
    #If you were using username to display to people you might want to get them to select one after registering through Facebook Connect
    def create_from_fb_connect(fb_user)
      # avoid user duplication
      return if User.exists?(:name => fb_user.name, :login => fb_login_for(fb_user))

      User.transaction do
        new_facebooker = User.new(:name => fb_user.name, :login => fb_login_for(fb_user), :email => '') # TODO get Email!
        new_facebooker.fb_user_id      = fb_user.uid.to_i
        new_facebooker.fb_session_key  = fb_user.session.session_key
        new_facebooker.fb_email_hash   = Facebooker::User.hash_email(new_facebooker.email)
        new_facebooker.skip_activation = true

        new_facebooker.save!
        new_facebooker.activate! # force activation

        new_facebooker.register_user_to_fb
      end
    end
  end

  # Checks whether the user is an fb_user
  # i.e., the user uses his/her Facebook's credentials to log into Bestdebates
  def fb_user?
    !!fb_user_id
  end
  
  # Checks whether the +fb_user_id+ of the user is equal to that of the user 
  # corresponding to the given +facebook_session+
  def equal_to_fb_user?(facebook_session)
    self.fb_user_id == facebook_session.user.id
  end

  # Connect the user object with a facebook id provided by the given +facebook_session+
  def link_fb_connect(facebook_session)
    return false if equal_to_fb_user?(facebook_session)

    User.transaction do
      if fb_user?
        fb_user_id       = facebook_session.user.id
        existing_fb_user = User.find_by_fb_user_id(fb_user_id)

        # unlink the existing account
        unless existing_fb_user.nil?
          existing_fb_user.fb_user_id = nil
          existing_fb_user.save!
        end

        self.fb_user_id = fb_user_id #link the new one
        self.save!
      end
    end
  end

  # Returns the +fb_user_id+ attribute of the user
  def facebook_id
    fb_user_id
  end

  # Returns the Facebook Session
  # Creates and returns it if it is not already created
  def fb_session
    @facebook_session ||=
      returning Facebooker::Session.create do |session|
        # Facebook sessions are good for only one hour after storing
        session.secure_with!(fb_session_key, fb_user_id, 1.hour.from_now)
    end
  end

  # Stores Facebook Session Key in the +fb_session_key+ attribute of the user
  def store_facebook_session(fb_session_key)
    update_attribute(:fb_session_key, fb_session_key) unless self.fb_session_key == fb_session_key
  end

  #The Facebook registers user method is going to send the users email hash and our account id to Facebook
  #We need this so Facebook can find friends on our local application even if they have not connect through connect
  #We hen use the email hash in the database to later identify a user from Facebook with a local user
  def register_user_to_fb
    Facebooker::User.register([{:email => self.email, :account_id => self.id}])
  end
end
