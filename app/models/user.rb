require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::StatefulRoles
  
  # Allowed sexes
  SEX = {'M' => 'Male', 'F' => 'Female'}

  # Existing roles in the app
  # Default is 'normal'
  ROLES = ['admin', 'special_sponsor', 'normal']

  ROLES.each do |role_name|
    define_method "#{role_name}?" do
      self.role == role_name
    end
  end

  # Allowed privacy levels of displaying birthdays on the users' profiles
  SHOW_BIRTHDAY_OPTIONS = {'SF' => 'Show my full birthday in my profile',
                           'SM' => 'Show only my birthday month in my profile',
                           'DS' => "Don't show my birthday in my profile"}
  
  concerned_with :callbacks, :fb_user, :finds, :validates
  
  file_column :image ,:magick => { :geometry => "120x140" },
                      :root_path => File.join(RAILS_ROOT, "public/system"),
                      :web_root => 'system/'#, :fix_file_extensions => false

  is_gravtastic :email, :secure => true, :size => 120#, :filetype => :gif

  default_values :role => 'normal'

  has_many :folders, :extend => UserFolderExtension
  after_create {
    |record|
    # Create the default folders for this record
    record.folders << Folder.new( :name => "Inbox" )
    record.folders << Folder.new( :name => "Outbox" )
  }
  has_many :authored_messages, :class_name => "PrivateMessage", :foreign_key => "author_id"

  belongs_to :group

  has_one :facebook_permission
  has_one :user_twitter_account
  has_many :logins,    :dependent => :nullify
  
  has_many :debates,   :order => 'created_at DESC',    :dependent => :destroy
  has_many :arguments, :order => 'created_at DESC',    :dependent => :destroy
    
  has_many :bookmarks, :order => 'bookmarks.created_at DESC',    :dependent => :destroy
  has_many :invitations, :foreign_key => 'invitor_id', :dependent => :destroy
  
  has_many :joined_debates, :class_name => 'UserResource', :dependent => :destroy
  has_many :authored_debates, :through => :joined_debates,  :source => :debate
  with_options :through => :joined_debates,  :source => :debate do |auth|
    auth.has_many :writable_authored_debates, :conditions => {:"user_debates.is_writable" => true}
    auth.has_many :readable_authored_debates, :conditions => {:"user_debates.is_writable" => false}
  end

  define_index do
    indexes [:login, :name]
    has  :id
    where "state='active'"
    
  set_property :enable_star => true
  set_property :min_prefix_len => 3
  end
  
  named_scope :active, lambda {
    { :conditions => {:state => 'active'} }
  }
  class << self
    # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
    #
    # uff.  this is really an authorization, not authentication routine.  
    # We really need a Dispatch Chain here or something.
    # This will also let us return a human error message.
    #
    def authenticate(login, password)
      u = find_in_state(:first, :active, :conditions => {:login => login}) # need to get the salt
      u && u.authenticated?(password) ? u : nil
    end

     def all_with_search_term(search_term)
      users = self.search search_term.to_s + '*', :field_weights => {:login => 5, :name => 1}
    end
    # This method is used to
    # find the user record  with given +identity_url+ and +registration+ if it already exists
    # OR
    # create such user
    def create_from_openid(identity_url, registration)
      user = User.find_or_initialize_by_identity_url(identity_url)

      User.transaction do
        user.login = registration['nickname']
        user.email = registration['email']
        user.skip_activation = true
        user.save!

        user.activate! # force activation
      end
      
      return user
    rescue ActiveRecord::RecordInvalid
      return user
    end
  end
  
  # Checks whether the user has logged in through OpenID
  def using_open_id?
    !identity_url.blank?
  end

  # Checks whether the user can change his/her password
  # changing password is allowed only for users who registered on bestdebates
  # i.e., not logged in using Facebook Connect or OpenID
  def can_change_password?
    standard_user?
  end

  # Checks whether the user is a standard_user i.e., not logged in using Facebook Connect or OpenID
  def standard_user?
    !using_open_id? && !fb_user?
  end
  
  # Returns +name+ attribute of the user
  # returns 'using OpenID' if the user is using_open_id? and +name+ attribute is blank
  # in all other cases returns the +name+ attribute as it is
  def name
    n = read_attribute(:name)
    return 'using OpenID' if using_open_id? and n.blank?
    n
  end
  
  # Returns +login+ attribute of the user
  # returns 'using OpenID' if the user is using_open_id? and +login+ attribute is blank
  # in all other cases returns the +login+ attribute as it is
  def login
    l = read_attribute(:login)
    return 'using OpenID' if l.blank? and using_open_id?
    l
  end
  
  # Sets email of the user from the given invitation code +icode+
  def use_invitation_code(icode)
    self.email = icode.invitation.email if icode and icode.invitation.guest?
  end
  
  # Resets the password of the user
  # i.e., generates a new activation_code
  # A mail is sent later with the new activation_code
  def reset_password!
    self.activation_code = self.class.make_token
    save!
  end
  def show_my_favorites?	 
      return self.show_favs   
  end
  def favorite_arguments(sort_by='argument_id')
    self.bookmarks.find(:all,:include=> :argument,:conditions => ['argument_id is not null'] , :order => "#{sort_by} desc")
  end
  def favorite_debates(sort_by='debate_id')
    self.bookmarks.find(:all,:include=> :debate,:conditions => ['debate_id is not null'] , :order => "#{sort_by} desc")
  end
  # Toggles +debate_or_argument+ bookmark of the user
  # i.e., if +debate_or_argument+ is not bookmarked, it is bookmarked
  # and   if +debate_or_argument+ is bookmarked, it is unbookmarked
  def toggle_bookmark!(debate_or_argument)
    bookmarked?(debate_or_argument) ? unbookmark(debate_or_argument) : bookmark(debate_or_argument)
  end
  
  # TODO. rewrite it thought Bookmark obj
  # Checks whether the +obj+ is bookmarked by the user
  def bookmarked?(obj)
    !obj.bookmark_by(self).nil?
  end

  def bookmarked_text(obj)
    bookmark = obj.bookmark_by(self)
    if !bookmark.nil?
      !bookmark.bookmark_text.blank? ? bookmark.bookmark_text : "No Bookmark Text"
    end
  end
  
  # Bookmarks the +obj+ for the user
  def bookmark(obj,bookmark_text=nil)
    Bookmark.create_obj(obj, self,bookmark_text) unless bookmarked?(obj)
  end 
  
  # Unbookmarks the +obj+ for the user
  def unbookmark(obj)
    obj.bookmark_by(self).destroy if bookmarked?(obj)
  end
    
  # Updates the +last_visited+ attribute of the user with the given datetime +t+
  def last_visited!(t)
    update_attribute(:last_visited, t)
  end

  # Enable API for the user
  def enable_api!
    self.generate_api_key!
  end

  # Disable API for the user
  def disable_api!
    self.update_attribute(:api_key, "")
  end

  # Check whether API is enabled for the user
  def api_is_enabled?
    !self.api_key.empty?
  end


  def my_bookmarked(obj)
     obj.bookmark_by(self)
  end

  def inbox
    folders.find_by_name("Inbox")
  end

  def outbox
    folders.find_by_name("Outbox")
  end
  
  protected

  # ...
  def secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end

  # Generate an API key for the user
  def generate_api_key!
    self.update_attribute(:api_key, secure_digest(Time.now, (1..10).map{ rand.to_s }))
  end

end
