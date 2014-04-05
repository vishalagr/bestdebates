class User < ActiveRecord::Base
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_protected :id, :crypted_password, :salt, :created_at, :updated_at, :remember_token, :remember_token_expires_at, :activation_code, :deleted_at, :last_visited

  default_values :show_sex => true, :show_birthday => 'SF', :use_gravatar => true, :arguments_count => 0

  with_options :if => :login_required? do |l|
    l.validates_presence_of   :login
    l.validates_length_of     :login,    :within => 3..40
    l.validates_uniqueness_of :login,    :case_sensitive => false
    l.validates_format_of     :login,    :with => RE_LOGIN_OK, :message => MSG_LOGIN_BAD
  end

  with_options :if => :name_required? do |n|
    n.validates_presence_of   :name
    n.validates_format_of     :name,     :with => RE_NAME_OK,  :message => MSG_NAME_BAD, :allow_nil => true
    n.validates_length_of     :name,     :maximum => 100
  end

  with_options :if => :website_required? do |w|
    w.validates_format_of     :website,
                                         :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix,
                                         :message => "must be a valid website"
  end

  with_options :if => :email_required? do |e|
    e.validates_presence_of   :email
    e.validates_length_of     :email,    :within => 6..100 #r@a.wk
    e.validates_uniqueness_of :email,    :case_sensitive => false
    e.validates_format_of     :email,    :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD
  end

  protected

  # overwrite the module's method
  # Checks if a password is required for the user
  #   All non- standard_user? s require a password
  #   All users with empty +crypted_password+ or non-empty +password+ attributes too require one
  def password_required?
    return false if using_open_id? || fb_user?
    crypted_password.blank? || !password.blank?
  end

  # Checks whether an email is required for the user
  # A user requires an email if he/she is not a fb_user?
  def email_required?
    !fb_user?
  end

  # Checks whether login is required for the user
  # A login is required if the user is not using_open_id?
  def login_required?
    !using_open_id?
  end

  # Checks whether name is required for the user
  # A name is required if the user is not using_open_id?
  def name_required?
    !using_open_id?
  end

  # Checks whether website is required for the user
  # A website is required if the user is not using_open_id?
  def website_required?
    !using_open_id?
  end
end
