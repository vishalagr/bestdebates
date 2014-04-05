# -*- coding: mule-utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe User do

  describe 'being created' do
    before do
      @user = nil
      @creating_user = lambda do
        @user = create_user
        violated "#{@user.errors.full_messages.to_sentence}" if @user.new_record?
      end
    end
    
    it 'increments User#count' do
      @creating_user.should change(User, :count).by(1)
    end

    it 'initializes #activation_code' do
      @creating_user.call
      @user.reload
      @user.activation_code.should_not be_nil
    end

    it 'starts in pending state' do
      @creating_user.call
      @user.reload
      @user.should be_pending
    end
  end

  #              
  # Validations
  #
 
  it 'requires login' do
    lambda do
      u = create_user(:login => nil)
      u.errors.on(:login).should_not be_nil
    end.should_not change(User, :count)
  end

	it 'requires name' do
		lambda do
      u = create_user(:name => nil)
      u.errors.on(:name).should_not be_nil
    end.should_not change(User, :count)
	end

  describe 'allows legitimate logins:' do
    ['123', '1234567890_234567890_234567890_234567890', 
     'hello.-_there@funnychar.com'].each do |login_str|
      it "'#{login_str}'" do
        lambda do
          u = create_user(:login => login_str)
          u.errors.on(:login).should     be_nil
        end.should change(User, :count).by(1)
      end
    end
  end
  describe 'disallows illegitimate logins:' do
    ['12', '1234567890_234567890_234567890_234567890_', "tab\t", "newline\n",
     "Iñtërnâtiônàlizætiøn hasn't happened to ruby 1.8 yet", 
     'semicolon;', 'quote"', 'tick\'', 'backtick`', 'percent%', 'plus+', 'space '].each do |login_str|
      it "'#{login_str}'" do
        lambda do
          u = create_user(:login => login_str)
          u.errors.on(:login).should_not be_nil
        end.should_not change(User, :count)
      end
    end
  end

  it 'requires password' do
    lambda do
      u = create_user(:password => nil)
      u.errors.on(:password).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires password confirmation' do
    lambda do
      u = create_user(:password_confirmation => nil)
      u.errors.on(:password_confirmation).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires email' do
    lambda do
      u = create_user(:email => nil)
      u.errors.on(:email).should_not be_nil
    end.should_not change(User, :count)
  end

  describe 'allows legitimate emails:' do
    ['foo@bar.com', 'foo@newskool-tld.museum', 'foo@twoletter-tld.de', 'foo@nonexistant-tld.qq',
     'r@a.wk', '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail.com',
     'hello.-_there@funnychar.com', 'uucp%addr@gmail.com', 'hello+routing-str@gmail.com',
     'domain@can.haz.many.sub.doma.in', 
    ].each do |email_str|
      it "'#{email_str}'" do
        lambda do
          u = create_user(:email => email_str)
          u.errors.on(:email).should     be_nil
        end.should change(User, :count).by(1)
      end
    end
  end
  describe 'disallows illegitimate emails' do
    ['!!@nobadchars.com', 'foo@no-rep-dots..com', 'foo@badtld.xxx', 'foo@toolongtld.abcdefg',
     'Iñtërnâtiônàlizætiøn@hasnt.happened.to.email', 'need.domain.and.tld@de', "tab\t", "newline\n",
     'r@.wk', '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail2.com',
     # these are technically allowed but not seen in practice:
     'uucp!addr@gmail.com', 'semicolon;@gmail.com', 'quote"@gmail.com', 'tick\'@gmail.com', 'backtick`@gmail.com', 'space @gmail.com', 'bracket<@gmail.com', 'bracket>@gmail.com'
    ].each do |email_str|
      it "'#{email_str}'" do
        lambda do
          u = create_user(:email => email_str)
          u.errors.on(:email).should_not be_nil
        end.should_not change(User, :count)
      end
    end
  end

  describe 'allows legitimate names:' do
    ['Andre The Giant (7\'4", 520 lb.) -- has a posse', 
     '1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890',
    ].each do |name_str|
      it "'#{name_str}'" do
        lambda do
          u = create_user(:name => name_str)
          u.errors.on(:name).should     be_nil
        end.should change(User, :count).by(1)
      end
    end
  end
  describe "disallows illegitimate names" do
    ["tab\t", "newline\n",
     '1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_',
     ].each do |name_str|
      it "'#{name_str}'" do
        lambda do
          u = create_user(:name => name_str)
          u.errors.on(:name).should_not be_nil
        end.should_not change(User, :count)
      end
    end
  end

	describe "determines admin privileges" do
		
#		it 'has admin privileges for admin user' do
#			user = create_user(:is_admin => true)
#			user.should be_admin
#		end
	
		it 'has normal privileges for normal user' do
			users(:quentin).should_not be_admin
		end
	end

  it 'resets password' do
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    User.authenticate('quentin', 'new password').should == users(:quentin)
  end

  it 'does not rehash password' do
    users(:quentin).update_attributes(:login => 'quentin2')
    User.authenticate('quentin2', 'monkey').should == users(:quentin)
  end

  #
  # Authentication
  #

  it 'authenticates user' do
    User.authenticate('quentin', 'monkey').should == users(:quentin)
  end

  it "doesn't authenticates user with bad password" do
    User.authenticate('quentin', 'monkey').should == users(:quentin)
  end

 if REST_AUTH_SITE_KEY.blank? 
   # old-school passwords
   it "authenticates a user against a hard-coded old-style password" do
     User.authenticate('old_password_holder', 'test').should == users(:old_password_holder)
   end
 else
   it "doesn't authenticate a user against a hard-coded old-style password" do
     User.authenticate('old_password_holder', 'test').should be_nil
   end

   # New installs should bump this up and set REST_AUTH_DIGEST_STRETCHES to give a 10ms encrypt time or so
   desired_encryption_expensiveness_ms = 0.1
   it "takes longer than #{desired_encryption_expensiveness_ms}ms to encrypt a password" do
     test_reps = 100
     start_time = Time.now; test_reps.times{ User.authenticate('quentin', 'monkey'+rand.to_s) }; end_time   = Time.now
     auth_time_ms = 1000 * (end_time - start_time)/test_reps
     auth_time_ms.should > desired_encryption_expensiveness_ms
   end
 end

  #
  # Authentication
  #

  it 'sets remember token' do
    users(:quentin).remember_me
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    users(:quentin).remember_me
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).forget_me
    users(:quentin).remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.from_now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'registers passive user' do
    user = create_user(:password => nil, :password_confirmation => nil)
    user.should be_passive
    user.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    user.register!
    user.should be_pending
  end

  it 'suspends user' do
    users(:quentin).suspend!
    users(:quentin).should be_suspended
  end

  it 'does not authenticate suspended user' do
    users(:quentin).suspend!
    User.authenticate('quentin', 'monkey').should_not == users(:quentin)
  end

  it 'deletes user' do
    users(:quentin).deleted_at.should be_nil
    users(:quentin).delete!
    #users(:quentin).deleted_at.should_not be_nil
    users(:quentin).should be_deleted
  end

  describe "being unsuspended" do
    fixtures :users

    before do
      @user = users(:quentin)
      @user.suspend!
    end
    
    it 'reverts to active state' do
      @user.unsuspend!
      @user.should be_active
    end
    
    it 'reverts to passive state if activation_code and activated_at are nil' do
      User.update_all :activation_code => nil, :activated_at => nil
      @user.reload.unsuspend!
      @user.should be_passive
    end
    
    it 'reverts to pending state if activation_code is set and activated_at is nil' do
      User.update_all :activation_code => 'foo-bar', :activated_at => nil
      @user.reload.unsuspend!
      @user.should be_pending
    end
  end

  describe "custom user methods" do

    before(:each) do
      @user = Factory.create(:user)
    end

    it "should find_all_active" do
      @user.state = 'active' and @user.save
      User.find_all_active.include?(@user).should be_true
    end

    it "should find public_debates" do
      debate = Factory.create(:public_debate, :user => @user)
      @user.public_debates.include?(debate).should be_true
    end

    it "should find public_arguments" do
      argument = Factory.create(:argument, :user => @user)
      @user.public_arguments.include?(argument).should be_true
    end

    it "should find invited_to debates" do
      invitation = Factory.create(:invitation, :user => @user)
      @user.invited_to.include?(invitation.resource).should be_true
    end

    it "should public_and_owned_in debates" do
      debate = Factory.create(:public_debate, :user => @user)
      @user.public_and_owned_in(@user.debates).include?(debate).should be_true
    end

    it "should password_edit_validation" do
      @user = Factory.build(:user, :password => 'some_pass', :identity_url => 'http://openid.aol.com/bestdebates')
      @user.send(:password_edit_validation).should be_false
      @user.errors['password'].should_not be_nil
    end

    it "should create a user from openid" do
      # CHECK + REFACTOR
      identity_url = 'http://openid.aol.com/bestdebates'
      registration = {'nickname' => 'bestdebates_user', 'email' => 'bestdebates@aol.com'}

      user = User.create_from_openid("http://openid.aol.com/u1", registration)
      (user.valid? and !user.new_record?).should be_true

      user = User.create_from_openid("http://openid.aol.com/u2", registration)
      (user.valid? and !user.new_record?).should be_false    # tried to create user with existent email 'bestdebates@aol.com'
    end

    it "should reset_password!" do
      @user.activation_code = nil and @user.save
      @user.reset_password!
      @user.activation_code.should_not be_nil
    end

    it "should toggle-bookmark and unbookmark" do
      arg = Factory.create(:argument, :user => @user)

      @user.bookmark(arg)

      @user.toggle_bookmark!(arg)
      @user.bookmarked?(arg).should be_false

      @user.toggle_bookmark!(arg)
      @user.bookmarked?(arg).should be_true

      @user.unbookmark(arg)
      @user.bookmarked?(arg).should be_false

      lambda { @user.bookmarked?(nil) }.should raise_error(NoMethodError)
    end

    it "should update last_visited" do
      t = DateTime.now
      @user.last_visited!(t)
      @user.read_attribute(:last_visited).should == t
    end

    it "should use_invitation_code" do
      code = Factory.create(:code, :invitation => Factory.create(:invitation, :email => 'xyz@bestdebates.com', :user => nil))
      @user.use_invitation_code(code)
      @user.email.should == code.invitation.email
    end

  end

  describe "fb_user" do
    before(:all) do
      @fb_session = Facebooker::Session.create(Facebooker.api_key, Facebooker.secret_key)
      @fb_user    = Facebooker::User.new(:session => @fb_session, :email_hashes => 'bestdebates', :uid => 1001, :name => 'FB User') 
    end

    before(:each) do
      @user = Factory.build(:user, :fb_email_hash => @fb_user.email_hashes, :fb_user_id => @fb_user.uid)
    end

    it "should find_by_fb_user" do
      @user.save
      User.find_by_fb_user(@fb_user).should == @user

      # password_edit_validation fails !!
      @user.update_attribute_with_validation_skipping(:fb_user_id, @fb_user.uid.to_i + 1)
      User.find_by_fb_user(@fb_user).should == @user

      @user.update_attribute_with_validation_skipping(:fb_email_hash, "some-different-hash")
      User.find_by_fb_user(@fb_user).should_not == @user
    end

    it "should find_by_fb_session" do
      # CHECK
      @user.save
      @fb_session.instance_variable_set(:@uid, @user.fb_user_id)

      u = User.find_by_fb_session(@fb_session)
      u.should == User.find_by_fb_user(@fb_session.user)
      u.fb_session_key.should == @fb_session.session_key
    end

    it "should get fb_login_for" do
      User.fb_login_for(@fb_user).should == "facebook_#{@fb_user.uid}"
    end
    # MERGE
    it "should create_from_fb_connect" do
      lambda {
        User.create_from_fb_connect(@fb_user)
      }.should_not raise_error

      @new_user = User.find_by_name_and_login(@fb_user.name, User.fb_login_for(@fb_user))
      @new_user.fb_user_id.should == @fb_user.uid.to_i
      @new_user.fb_session_key.should == @fb_user.session.session_key
      @new_user.fb_email_hash.should == Facebooker::User.hash_email(@new_user.email)
      @new_user.activated_at.should_not be_nil

      lambda { User.create_from_fb_connect(@fb_user) }.should_not raise_error
      lambda { User.create_from_fb_connect(@fb_user) }.should_not change(User, :count)
    end

    it "should check whether the user is a fb_user" do
      @user.fb_user?.should be_true
      @user.fb_user_id = nil
      @user.fb_user?.should be_false
    end

    it "should check whether the user is equal_to_fb_user" do
      @fb_session.instance_variable_set(:@uid, @user.fb_user_id)

      @fb_session.user.id = @user.fb_user_id
      @user.equal_to_fb_user?(@fb_session).should be_true

      @fb_session.user.id = @user.fb_user_id + 1
      @user.equal_to_fb_user?(@fb_session).should be_false
    end
    # MERGE BOTH
    it "should link_fb_connect" do
      @fb_session.instance_variable_set(:@uid, @user.fb_user_id)

      @fb_session.user.id = @user.fb_user_id
      @user.link_fb_connect(@fb_session).should be_false

      @fb_session.user.id = @user.fb_user_id + 1
      existing_user = Factory.create(:user, :fb_user_id => @fb_session.user.id)
      lambda { @user.link_fb_connect(@fb_session) }.should_not raise_error
      User.find(existing_user.id).fb_user_id.should be_nil        # Prevent caching
      @user.fb_user_id.should == @fb_session.user.id
    end

    it "should get facebook_id" do
      @user.facebook_id.should == @user.fb_user_id
      @user.fb_user_id = nil
      @user.facebook_id.should be_nil
    end

    it "should get fb_session" do
      lambda {
        session = @user.fb_session
        session.is_a?(Facebooker::Session).should be_true
      }.should_not raise_error
    end

    it "should store_facebook_session" do
      # CHECK
      @user.save
      @user.store_facebook_session('session-key')
      @user.fb_session_key.should == 'session-key'
    end

    it "should register_user_to_fb" do
      @user.register_user_to_fb.should == Facebooker::User.register([{:email => @user.email, :account_id => @user.id}])
    end
  end


  protected

  def create_user(options = {})
    record = User.new({ :login => 'quirex', :name => 'Quentin', :email => 'quirex@example.com', :password => 'quire69', :password_confirmation => 'quire69' }.merge(options))
    record.register! if record.valid?
    record
  end
end
