require File.dirname(__FILE__) + '/../spec_helper'
include AuthenticatedSystem

describe UsersController do
  fixtures :users

  include CustomFactory
  include MockFactory

  before(:all) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    @deliveries = ActionMailer::Base.deliveries = []
  end

  it 'initializes new user' do
    lambda do
      get :new
      assigns(:user).new_record?.should be_true
    end.should_not change(User, :count)

    # With code from params
    code = Factory.create(
      :code,
      :unique_hash => (uniq_hash = 'c67dec16f3e99b4b901ccffca30497b5855b1ee0'),
      :invitation => Factory.create(:guest_invitation)
    )
    get :new, { :code => uniq_hash }
    assigns(:user).email.should == code.invitation.email
  end

  it 'activates account after signup' do
    lambda do
      post :create, {:user => Factory.attributes_for(:user)}
      response.should be_redirect
    end.should change(User, :count).by(1)

    assigns(:user).activated_at.should be_nil
    assigns(:user).state.should_not == 'active'
  end

  it 'redirects to the invited debate after signup' do
    code = Factory.create(
      :code,
      :unique_hash => (uniq_hash = 'c67dec16f3e99b4b901ccffca30497b5855b1ee0'),
      :invitation => Factory.create(:guest_invitation)
    )
    post :create, {:user => Factory.attributes_for(:user), :code => uniq_hash}
    response.should redirect_to(debate_url(code.invitation.resource))
  end

  it 'edit password' do
    user = Factory.create(:user)
    controller.stub!(:user_editable?).and_return(true)
    post :edit_password, {:id => user.id, :user => {:password => 'abcdefg', :password_confirmation => 'abcdefg'}}

    assigns(:user).password.should == 'abcdefg'
    response.should be_success
    flash[:notice].should == 'Your changes have been saved'
  end

  describe 'facebook session' do
    before(:each) do
      @fb_session = Facebooker::Session.create
      @fb_session.instance_variable_set(:@uid, 1)
      @fb_session.user.name = "Some Facebook Name"
    end

    after(:each) do
      response.should be_redirect
    end

    it 'links user accounts [not logged in]' do
      #self.stub!(:facebook_session).and_return(@fb_session)
      User.should_receive(:create_from_fb_connect).once
      post :link_user_accounts, {}, {:facebook_session => @fb_session, :user_id => nil}
    end

    it 'links user accounts [not logged in]' do
      @user = User.find(1)
      login_as(:quentin)
      self.stub!(:current_user).and_return(@user)
      #@user.should_receive(:link_fb_connect)
      post :link_user_accounts, {}, {:facebook_session => @fb_session}
    end

  end

  it 'resets forgot password' do
    user = Factory.create(:user, :state => 'active', :activated_at => Time.now)
    Mailers::User.should_receive(:deliver_password_reset).with(user).once
    xhr :post, :forgot_password, {:email => user.email}
    assigns(:user).should_not be_nil
    flash[:notice].should == 'We have emailed you a message with instructions for resetting your password.'
    response.should be_success

    xhr :post, :forgot_password, {:email => '23984234'}
    assigns(:user).should be_nil
    flash[:error].should == 'No member record matching email address was found.'
  end

  it 'renders tooltip' do
    user = Factory.create(:user)
    xhr :get, :tooltip, {:id => user.id}
    response.should be_success
  end

  it 'allows signup' do
    lambda do
      create_user
      response.should be_redirect
    end.should change(User, :count).by(1)
  end
  
  it 'signs up user in active state' do
    create_user
    assigns(:user).reload
    assigns(:user).should be_pending
  end

  it 'signs up user with activation code' do
    create_user
    assigns(:user).reload
    assigns(:user).activation_code.should_not be_nil
  end
  it 'requires login on signup' do
    lambda do
      create_user(:login => nil)
      assigns[:user].errors.on(:login).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password on signup' do
    lambda do
      create_user(:password => nil)
      assigns[:user].errors.on(:password).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password confirmation on signup' do
    lambda do
      create_user(:password_confirmation => nil)
      assigns[:user].errors.on(:password_confirmation).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires email on signup' do
    lambda do
      create_user(:email => nil)
      assigns[:user].errors.on(:email).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  # activates... merge
  # DISABLING THE NEED FOR ACTIVATING THE ACCOUNT TEMPORARILY
  it 'activates user on signup' do
    create_user
    assigns[:user].activated_at.should be_nil
    assigns[:user].state.should == "pending"
  end
  
  it 'activates user' do
    User.authenticate('aaron', 'monkey').should be_nil
    get :activate, :activation_code => users(:aaron).activation_code
    response.should redirect_to(debates_url)
    flash[:notice].should_not be_nil
    flash[:error ].should     be_nil
    User.authenticate('aaron', 'monkey').should == users(:aaron)
  end
  
  it 'does not activate user without key' do
    get :activate
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end
  
  it 'does not activate user with blank key' do
    get :activate, :activation_code => ''
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end
  
  it 'does not activate user with bogus key' do
    get :activate, :activation_code => 'i_haxxor_joo'
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end
  
	it 'requires login for edit' do
		get :edit, :id => users(:quentin).id
		response.should redirect_to(new_session_path)
	end
	
	it 'shows edit form when logged in' do
		login_as(:quentin)
		get :edit, :id => users(:quentin).id
		response.should be_success
	end
	
	describe 'PUT /users/1/update' do
		before :each do
			@user = users(:quentin)
			@attributes = { :name => 'Joe Schmoe', :login => 'joe', :email => 'joe@example.com' }
		end
		
		def do_put
			put :update, :id => @user.id, :user => @attributes
		end
			
		it 'requires login' do
			do_put
			response.should redirect_to(new_session_path)
		end
		
		it 'updates user information' do
			login_as(:quentin)
			self.stub!(:current_user).and_return(@user)
			do_put
			response.should be_success
			flash[:notice].should == 'Your changes have been saved'
			flash[:error].should be_nil
		end
		
		it 'reports an error if updated attributes are not correct' do
			login_as(:quentin)
			@attributes[:email] = 'foo'
			do_put
			response.should be_success
			flash[:notice].should be_nil
		end
		
		it 'reports an error if updated passwords do not match' do
			login_as(:quentin)
			@attributes[:password] = 'Fred'
			@attributes[:password_confirmation] = 'Ernie'
			do_put
			response.should be_success
			flash[:notice].should be_nil
		end
	end
	
	describe 'POST /forgot_password' do

		def do_post(email)
			xhr :post, :forgot_password, :email => email
		end
		
		it 'sends a reminder email for user' do
			user = users(:aaron)
			User.stub!(:find_by_email).and_return(user)
			Mailers::User.should_receive(:deliver_password_reset).with(user).once
			do_post(user.email)
			response.should be_success
		end
		
		it 'reports error if user is not found' do
			Mailers::User.should_receive(:deliver_password_reset).never
			do_post('foo@bar.com')
			response.should be_success
		end
		
		it 'ignores non-XHTTP requests' do
			get :forgot_password, :email => 'users(:aaron).email'
			response.should redirect_to(debates_path)
		end
	end
	
	describe 'GET /reset_password' do
		it 'logs in user and renders change form for password reset requests' do
			user = users(:aaron)
			User.stub!(:find_by_activation_code).and_return(user)
			get :reset_password, :activation_code => user.activation_code
			response.should redirect_to(change_password_user_path(user))
		end

		it 'redirects to home page for invalid requests' do
			User.stub!(:find_by_activation_code).and_return(nil)
			get :reset_password, :activation_code => 'XXX'
			response.should redirect_to(debates_path)
      flash[:error].should == "Invalid reset-password url. Use the link provided in the reset email."
		end
	end
	
  it 'handle GET /users/users_search' do
    @user = mock_user
    User.should_receive(:active).and_return(User)
    User.should_receive(:all).with({
      :conditions => ["LOWER(login) LIKE ? OR LOWER(name) LIKE ?", "%xyz%", "%xyz%"],
      :order      => 'login ASC'
    }).and_return([@user])

    get :users_search, :query => 'xyz'
    response.should be_success
    response.should render_template('invitations/_users_select')
  end

  describe 'handle POST /users with sponsor_save' do
    before(:each) do
      @user = mock_user(:id => 5)
      @invitation, @invite_link, @code = mock_model(Invitation), mock_model(InviteLink), mock_model(Code)

      SponsorUser.stub!(:save_org_user)
      controller.stub!(:current_user).and_return(@user)
      controller.stub!(:update_logins)
    end

    it 'should not save sponsor_user when checkbox is not checked' do
      SponsorUser.should_not_receive(:save_org_user)

      post :create, {:user => {}}
    end

    it 'should save sponsor_user when using invitation link' do
      SponsorUser.should_receive(:save_org_user).with(3, 5).once
      InviteLink.should_receive(:find_by_unique_id).with('1234').and_return(@invite_link)
      @invite_link.should_receive(:user_id).and_return(3)

      post :create, {:sponsor_allow => true}, {:unique_code => '1234'}
    end

    it 'should save sponsor_user when using invite_link' do
      SponsorUser.should_receive(:save_org_user).with(3, 5).once
      Code.should_receive(:find_by_unique_hash).with('1234').and_return(@code)
      @code.should_receive(:invitation).and_return(@invitation)
      @invitation.should_receive(:invitor_id).and_return(3)

      post :create, {:sponsor_allow => true}, {:invitation_code => '1234'}
    end
  end

  describe 'handle GET /users/new for group_signup' do
    before(:each) do
      @user = mock_user(:id => 5)
      @user.stub!(:use_invitation_code)
      User.stub!(:new).and_return(@user)

      @group = mock_model(Group, :id => 1)

      controller.stub!(:find_invitation_code)
      controller.stub!(:update_logins)
    end

    it 'should assign user.group_id as a hidden field' do
      Group.stub!(:find_by_unique_hash).with('xyz').once.and_return(@group)
      @user.should_receive(:group_id=).with(@group.id).once.and_return(true)

      get :new, :hash => 'xyz'
      assigns[:group].should == @group
      response.should be_success
    end

    it 'should not raise error and display select tag if unique_hash is invalid' do
      Group.stub!(:find_by_unique_hash).with('xyz').once.and_return(nil)
      @user.should_not_receive(:group_id)

      get :new
      assigns[:group].should be_nil
      response.should be_success
    end
  end

  def create_user(options = {})
    post :create, :user => Factory.attributes_for(:user).merge(options)
  end
end
