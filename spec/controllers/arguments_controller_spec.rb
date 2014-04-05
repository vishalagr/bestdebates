require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArgumentsController do 
	
  include CustomFactory
	include MockFactory	

	describe "handling GET '/debates/1/arguments/2'" do
		before :each do
      @user = mock_user
			@debate = mock_debate(:user => @user)
			@argument = mock_argument(:user => @user)
			Debate.stub!(:find).and_return(@debate)
			Argument.stub!(:find).and_return(@argument)
      @argument.stub!(:visible_to?).and_return(true)
			@arguments = mock("Array of debate.arguments", :find => @argument)
			@debate.stub!(:arguments).and_return(@arguments)	
      self.stub!(:current_user).and_return(@user)
		end
		
		def do_get
			get :show, :debate_id => @debate.id, :id => @argument.id
		end
	
    it "should redirect to home url if arg is not visible for user" do
      @argument.stub!(:visible_to?).and_return(false)
      login_as(:quentin)
      do_get
      response.should redirect_to(root_url)
    end

    # TODO figure out how to get these tests to pass
    it "should show ratings form if logged in"  do
      login_as(:quentin)
      do_get
      assigns[:user].should == users(:quentin)
      response.should be_success
    end

    it "should display login link if not logged in"	 do
      do_get
      assigns[:user].should be_nil
      response.should be_success
    end
	end
	
	describe "handling GET '/debates/1/arguments/new'" do
		before :each do 
			@debate = mock_debate
			@argument = mock_argument
			Debate.stub!(:find).and_return(@debate)
			@arguments = mock("Array of debate.arguments", :new => @argument)
			@debate.stub!(:arguments).and_return(@arguments)
      @debate.stub!(:is_freezed).and_return(false)
			@debate.stub!(:public?).and_return(true)
      @argument.stub!(:debate=).and_return(true)
			@argument.stub!(:public?).and_return(true)
			
			Argument.stub!(:new).and_return(@argument) 
		end
		
		def do_get
			get :new, :debate_id => @debate.id
		end

		it "should redirect if not logged in" do 
			do_get
			response.should redirect_to(new_session_path)
		end

    #it 'should redirect if the user cannot create argument' do
		#	@debate.stub!(:public?).and_return(false)
		#	@debate.stub!(:owner?).and_return(false)
		#	@debate.stub!(:joined_users).stub!(:find_by_user_id).and_return([])
		#	login_as(:quire)
    #  do_get
    #  #response.should redirect_to(debate_url(@debate))
    #  flash[:error].should == 'You have\'nt permission to create argument'
    #end

	 	it "should load debate" do
			login_as(:quentin)
			do_get
			assigns[:debate].should == @debate 
		end
		
	 	it "should render new template" do
			login_as(:quentin)
			do_get
			response.should render_template(:new)
		end
  end

  describe "handling GET '/debates/1/arguments/new' errors " do
	 	it "should respond with status 404 if debate not found" do
      login_as(:quentin)
			get :new, :debate_id => '12345'
      response.should render_template("#{RAILS_ROOT}/public/404.html")
		end
	end

	# GET /arguments/1/edit 

	describe "handling '/arguments/1/edit'" do
		before :each do
			@debate   = mock_debate
			@argument = mock_argument(:debate => @debate)
			Debate.stub!(:find).and_return(@debate)
			Argument.stub!(:find).and_return(@argument)
      @argument.stub!(:owner?).and_return(true)
      @argument.stub!(:immutable?).and_return(false)
			@arguments = mock("Array of debate.arguments", :find => @argument)
			@debate.stub!(:arguments).and_return(@arguments)
      @debate.stub!(:is_freezed).and_return(false)
		end
		
		def do_get
			get :edit, :id => '1'
		end
		
		it "should render template if current_user is owner" do		
			login_as(:quentin)	
			do_get
      response.should render_template(:edit)
		end

	 	it "should load debate and argument" do
	 		login_as(:admin)
			do_get
			assigns[:argument].should == @argument
	 	end

	 	it "should render form" do
			login_as(:admin)
			do_get
			response.should render_template(:edit)
		end
	end

	# POST /debates/1/arguments 
	
	describe "handling POST '/debates/1/arguments'" do
		describe "successful save" do
			before :each do
				@debate = mock_debate
				@argument = mock_argument

				Argument.stub!(:create).and_return(@argument)
				@argument.stub!(:valid?).and_return(true)
        @argument.stub!(:public?).and_return(true)
        @argument.stub!(:destroy_unfreeze_errors_keep).and_return(@argument)

        @debate.stub!(:public?).and_return(true)
        @debate.stub!(:is_freezed).and_return(false)
        @debate.stub!(:is_live?).and_return(true)
				login_as(:quentin)
				Debate.stub!(:find).and_return(@debate)

				@arguments = mock("Array of debate.arguments", :new => @argument)
				@arguments.stub!(:find).and_return(@arguments)
				@debate.stub!(:arguments).and_return(@arguments)
			end
		
			def do_post(attributes = {})
				post :create, {:debate_id => @debate, :argument => valid_argument_attributes}.merge(attributes)
			end		

		 	it "should successfully create new argument" do
				Argument.should_receive(:create_child).and_return(@argument)
				do_post
			end

		 	it "should redirect to debate page" do
				login_as(:quentin)
				do_post
				response.should be_redirect
			end
			
			it "should create child argument when a parent is given" do
				login_as(:quentin)
				parent = mock_argument
				Argument.stub!(:find).and_return(parent)
				attribs = valid_argument_attributes.merge(:user => users(:quentin), :debate => @debate)
        attribs['parent_id'] = parent.id
				attribs.stringify_keys!
				Argument.should_receive(:create_child).with(attribs, parent).once.and_return(@argument)
				post :create, :debate_id => @debate.id, :argument => attribs, :parent_id => parent.id
			end
		end
		
		describe "failed save" do
			
			it "should redirect if not logged in" do
				@debate = mock_debate
				Debate.stub!(:find).and_return(@debate)
				post :create, :debate_id => @debate, :argument => valid_argument_attributes
				response.should redirect_to(new_session_path)
			end

		 	it "should throw ContentNotFoundException if debate not found" do
        login_as(:quentin)
				get :new, :debate_id => '12345'
        response.should render_template("#{RAILS_ROOT}/public/404.html") 
			end

		 	it "should render form if validation failed" do
				@debate = mock_debate
				@argument = mock_argument
				Argument.stub!(:create).and_return(@argument)
				@argument.stub!(:valid?).and_return(false)
				@arguments = mock("Array of debate.arguments", :new => @argument)
				@arguments.stub!(:find).and_return(@arguments)
				@debate.stub!(:arguments).and_return(@arguments)
        @debate.stub!(:public?).and_return(true)
        @debate.stub!(:is_live?).and_return(true)
        @debate.stub!(:is_freezed).and_return(false)
				Debate.stub!(:find).and_return(@debate)
				login_as(:quentin)
        attribs = valid_argument_attributes
        attribs.delete(:title)
				post :create, :debate_id => @debate, :argument => attribs
				response.should render_template(:new)
			end			
		end 
	end

	# PUT /debates/1/arguments/1 
	describe "handling PUT '/debates/1/arguments/1'" do
	
		before :each do
			@debate = mock_debate
			@argument = mock_argument(:debate => @debate)
			Debate.stub!(:find).and_return(@debate)
      Argument.stub!(:find).and_return(@argument)
      @argument.stub!(:debate).and_return(@debate)
      @argument.stub!(:set_status_from_buttons).and_return(true)
      @argument.stub!(:owner?).and_return(true)
      @argument.stub!(:immutable?).and_return(false)
			@arguments = mock("Array of debate.arguments")
			@arguments.stub!(:find).and_return(@argument)
			@debate.stub!(:arguments).and_return(@arguments)
      @debate.stub!(:is_freezed).and_return(false)
		end
					
		def do_put
			put :update, :id => @argument.id, :argument => {:title => nil}
		end
			
		describe "successful update" do
			
			before :each do
        @argument.stub!(:update_attributes).and_return(false)
				self.stub!(:find_argument).and_return(@argument)
				login_as(:admin)
				@argument.should_receive(:update_attributes).once.and_return(true)
			end
		
		 	it "should successfully update argument" do
				do_put
				response.should be_redirect
			end
		
		end
		
		describe "failed update of argument" do
			
		 	it "should render form if validation failed" do
				login_as(:admin)
				@argument.should_receive(:update_attributes).once.and_return(false)
				do_put
				response.should render_template(:edit)
			end
		end
	end

	# DELETE /debates/1/arguments/1 

	describe "handling DELETE '/debates/1/arguments/1'" do 
		
		before :each do
			@debate = mock_debate
			@argument = mock_argument(:debate => @debate)
			@argument.stub!(:destroy).and_return(true)
			@argument.stub!(:owner?).and_return(true)
			@argument.stub!(:immutable?).and_return(false)
      @argument.stub!(:parent).and_return(nil)
			Argument.stub!(:find).and_return(@argument)
			Debate.stub!(:find).and_return(@debate)
			@arguments = mock("Array of debate.arguments")
			@arguments.stub!(:find).and_return(@argument)
			@debate.stub!(:arguments).and_return(@arguments)
      @debate.stub!(:is_freezed).and_return(false)
		end
		
		def do_delete
			@request.env['HTTP_REFERER'] = "http://referrer"
			delete :destroy, :id => @argument
		end
		
		it "should redirect if not admin" do
			login_as(:quentin)	
			do_delete
			response.should redirect_to(debate_path(@debate))
		end

	 	it "should delete argument" do
			login_as(:admin)
			@argument.should_receive(:destroy).once
			do_delete
		end
		
	 	it "should redirect to debate page" do
			login_as(:admin)
			do_delete
			response.should redirect_to(debate_url(@debate))
		end

    it "should redirect to argument if parent exists" do
      @argument.stub!(:parent).and_return(@argument)
      login_as(:admin)
      do_delete
      response.should redirect_to(argument_url(@argument.parent))
    end
	 
	end
	
	# TODO we really don't need debate here -- how do we fix this in the controller?
	describe "handling POST '/debates/1/arguments/2/rate'" do
		before :each do
			@debate = mock_debate
			@ratings = Array.new
			@argument = mock_argument(:ratings => @ratings)
			@rating_params = {
	      'clarity_average' => 5,
				'accuracy_average' => 8,
	      'relevance_average' => 3
	    }
			Argument.stub!(:find).and_return(@argument)
			Debate.stub!(:find).and_return(@debate)
			@argument.stub!(:ratings).and_return(@ratings)
			@argument.stub!(:reload)
			@argument.stub!(:owner?).and_return(false)  # one shouldn't rate his/her argument
			@argument.stub!(:immutable?).and_return(false)
			@arguments = mock("Array of debate.arguments", :<< => true)
			@debate.stub!(:arguments).and_return(@arguments)
      @debate.stub!(:is_freezed).and_return(false)
			@rating = mock_rating(:accuracy => nil, :clarity => nil, :relevance => nil)
			Rating.stub!(:new).and_return(@rating)
		end
		
		def do_post
			post :rate, {:id => @argument.id, :debate_id => @debate.id}.merge(@rating_params)
		end
		
		it "should require login" do
			do_post
			response.should redirect_to(new_session_url)
		end
		
		it "should save valid rating" do
			user = users(:quentin)
			login_as(:quentin)
			@argument.should_receive(:rate!).with(user, {:clarity => '5', :accuracy => '8', :relevance => '3'}).once.and_return(@rating)
			do_post
			flash[:notice].should == "Rating Saved"
		end
		
		it "should report error if rating is not valid" do
			@rating_params['accuracy_average'] = nil
			user = users(:quentin)
			login_as(:quentin)
			@argument.should_receive(:rate!).with(user, {:clarity => '5', :accuracy => nil, :relevance => '3'}).once.and_raise(ActiveRecord::RecordNotSaved)
			do_post
			flash[:error].should == "Please select a choice for all parameters"
		end
		
	end

  describe 'handling GET /arguments/1/publish /arguments/1/unpublish' do
    before(:each) do
      @argument = mock_argument
      Argument.stub!(:find).and_return(@argument)
    end

    after(:each) do
      response.should redirect_to(argument_url(@argument))
    end

    it 'should publish an argument' do
      @argument.should_receive(:publish).once
      get :publish, :id => @argument.id
    end

    it 'should unpublish an argument' do
      @argument.should_receive(:unpublish).once
      get :unpublish, :id => @argument.id
    end
  end

  it 'handles GET /arguments/' do
    @user = users(:quentin)
    login_as(:quentin)
    self.stub!(:current_user).and_return(@user)
    params = {'controller' => 'arguments', 'action' => 'index'}
    Argument.should_receive(:recent).with(@user, params).once

    get :index
    response.should be_success
    response.should render_template(:index)
  end

  it 'handles GET /arguments/1/rss/deep/:deep.xml' do
    @argument = mock_argument
    Argument.stub!(:find).and_return(@argument)

    get :rss, :id => @argument.id, :deep => '103'
    assigns[:deep].should == 103
    response.should be_success
  end

  it 'handles GET /arguments/1/tooltip' do
    @argument = mock_argument
    Argument.stub!(:find).and_return(@argument)
    @user = users(:quentin)
    login_as(:quentin)
    self.stub!(:current_user).and_return(@user)

    get :tooltip, :id => @argument.id
    response.should be_success
    assigns[:user].should == @user
  end

  describe 'handle PUT /arguments/1/add_tag' do
    before(:each) do
      @debate   = mock_debate
      @argument = mock_argument(:debate => @debate)
      @user = users(:quentin)
      @tag_list = TagList.new
      @tags = 'tag_1, tag_2, tag_3'
      Argument.stub!(:find).and_return(@argument)
      self.stub!(:current_user).and_return(@user)
      @argument.stub!(:tag_list).and_return(@tag_list)
      @argument.stub!(:owner?).and_return(true)
      @debate.stub!(:is_freezed).and_return(false)
    end

    def do_add_tag
      put :add_tag, {:id => @argument.id, :tag => @tags}
    end

    it 'redirect to login page if not logged in' do
      do_add_tag
			response.should redirect_to(new_session_path)
    end

    it 'tag_list updated successfully' do
      @tag_list.should_receive(:add).with( @tags.split(',') ).once
      @argument.should_receive(:save).and_return(true)

      login_as(:quentin)
      do_add_tag
      response.should redirect_to(argument_url(@argument))
      flash[:notice].should == 'The tags were successfully added.'
    end

    it 'tag_list not updated' do
      @tag_list.should_receive(:add).with( @tags.split(',') ).once
      @argument.should_receive(:save).and_return(false)

      login_as(:quentin)
      do_add_tag
      response.should redirect_to(argument_url(@argument))
      flash[:error].should == 'Can\'t add the tag'
    end
  end

  describe 'handle PUT /arguments/1/bookmark and /arguments/1/unbookmark' do

    before(:each) do
      @argument = mock_argument
      @user = users(:quentin)
      Argument.stub!(:find).and_return(@argument)
      self.stub!(:current_user).and_return(@user)

      login_as(:quentin)
    end

    it 'bookmarks' do
      @argument.stub!(:bookmark_by).and_return(true)
      put :bookmark, :id => @argument.id
      #@user.should_receive(:bookmark).with(@argument).once.and_return(true)
      response.should be_success
    end
    
    it 'unbookmarks' do
      @argument.stub!(:bookmark_by).and_return(nil)
      put :unbookmark, :id => @argument.id
      #@user.should_receive(:unbookmark).with(@argument).once.and_return(true)
      response.should be_success
    end
  end

  describe 'handle POST /arguments/1/send_email' do
    before(:each) do
			@argument = mock_argument
      Argument.stub!(:find).and_return(@argument)
    end

    it 'delivers email successfully' do
      Mailers::Debate.should_receive(:deliver_send_email).with(@argument, 5, 'someone@bestdebates.com').once.and_return(true)
      post :send_email, {:id => 1, :email => 'someone@bestdebates.com', :depth => 5, :format => 'js'}
      response.should have_rjs
      flash[:notice].should == 'Email successfully sent!'
    end

    it 'gives error message' do
      Mailers::Debate.should_not_receive(:deliver_send_email)
      post :send_email, {:id => 1, :email => 'someonebestdebatescom', :format => 'js'}
      response.should have_rjs
      flash[:error].should == 'Invalid email address'
    end
  end

  describe 'handle POST /arguments/1/report_offensive' do
    before(:each) do
			@argument = mock_argument
      @user = mock_user
      Argument.stub!(:find).and_return(@argument)
      controller.stub!(:featured_debates).and_return([])
      controller.stub!(:update_logins).and_return(true)
      Mailers::Debate.stub!(:deliver_offensive_report)
    end

    def do_report_offensive
      post :report_offensive, {:id => 1, :format => 'js'}
    end

    it 'redirects to debates_url if not logged in' do
      Mailers::Debate.should_not_receive(:deliver_offensive_report)
      do_report_offensive
    end

    it 'delivers email successfully' do
      login_as(:quentin)
      controller.stub!(:current_user).and_return(@user)
      Mailers::Debate.should_receive(:deliver_offensive_report).with(@argument, @user).once.and_return(true)
      do_report_offensive
      response.should have_rjs
      flash[:notice].should == "Thank You. This has been reported to our administrative review"
    end

    it 'gives error message' do
      login_as(:quentin)
      controller.stub!(:current_user).and_return(@user)
      Mailers::Debate.should_receive(:deliver_offensive_report).and_raise(NoMethodError)
      do_report_offensive
      response.should have_rjs
      flash.now[:error].should == "Couldn't report as offensive. Contact your administrator"
    end
  end

  describe 'check check_freezed' do
    before(:each) do
      @debate   = mock_debate
			@argument = mock_argument(:debate => @debate)
      @user = mock_user

      @debate.stub!(:is_freezed).and_return(true)
			@debate.stub!(:public?).and_return(true)
      Argument.stub!(:find).and_return(@argument)
      Debate.stub!(:find).and_return(@debate)
      controller.stub!(:featured_debates).and_return([])
      controller.stub!(:update_logins).and_return(true)
      login_as(:quentin)

      @flash_error = 'The argument you are trying to edit belongs to a freezed debate and thus is freezed'
    end

    it 'handle GET /debates/1/arguments/new for an unfreezed argument' do
      @debate.should_receive(:is_freezed).and_return(false)
      controller.stub!(:new).and_return(true)

      get :new, :id => 1
    end

    it 'handles :new and :create' do
      @debate.should_receive(:is_freezed).and_return(true)

      post :create, :id => 1
      response.should redirect_to(debate_path(@debate))
      flash[:error].should == @flash_error
    end

    it 'handles :edit, :update, :rate, :add_tag, :destroy' do
      @debate.should_receive(:is_freezed).and_return(true)

      post :add_tag, :id => 1
      response.should redirect_to(argument_path(1))
      flash[:error].should == @flash_error
    end

    it 'handles tab actions' do
      @debate.should_receive(:is_freezed).and_return(true)

      post :tab, :tab => Argument::TABS[:edit], :id => 1
      response.should have_rjs
    end
  end

  describe 'handle POST /debates/1/arguments/xml_import' do
    before :each do
      @debate   = mock_debate
			@argument = mock_argument(:debate => @debate)
      @user = mock_user

      @debate.stub!(:is_freezed).and_return(true)
			@debate.stub!(:public?).and_return(true)
      Argument.stub!(:find).and_return(@argument)
      Debate.stub!(:find).and_return(@debate)
      controller.stub!(:featured_debates).and_return([])
      controller.stub!(:update_logins).and_return(true)

      @xml_file = mock(File, :read => '')
      @xml      = mock(Nokogiri::XML::Document)
      @argument = mock_argument
      Argument.stub!(:create).and_return(@argument)
      @argument.stub!(:move_to_child_of).and_return([])
      @xml.stub!(:xpath).and_return([@xml])
      controller.stub!(:recursive_insert)

      login_as(:quentin)
    end

    def do_xml_import
      post :xml_import, {:debate_id => 1, :parent_id => '123', :xml_file => @xml_file}
    end

    it 'imports successfully' do
      Nokogiri.should_receive(:XML).with('').once.and_return(@xml)
      @xml.should_receive(:xpath).with('/argument').and_return([@xml])

      do_xml_import
      flash[:notice].should == 'Arguments successfully imported'
      response.should redirect_to(debate_path(@debate))
    end

    it 'fails to import' do
      Nokogiri.should_receive(:XML).with('').once.and_raise(NoMethodError)

      do_xml_import
      flash[:error].should == 'Invalid XML'
      response.should redirect_to(debate_path(@debate))
    end
  end

  describe 'handle GET /arguments/1/invlink/1234' do
    before(:each) do
      @user = mock_user
			@debate = mock_debate(:user => @user)
			@argument = mock_argument(:user => @user)
			Debate.stub!(:find).and_return(@debate)
			Argument.stub!(:find).and_return(@argument)
      @argument.stub!(:visible_to?).and_return(true)
			@arguments = mock("Array of debate.arguments", :find => @argument)
			@debate.stub!(:arguments).and_return(@arguments)	

      @invite_link = mock_model(InviteLink, :id => 1)
      @invite_link.stub!(:connect!)
      self.stub!(:current_user).and_return(@user)
      self.stub!(:store_location)
    end

    def do_get(attribs = {})
      get :show, {:id => 1, :unique_id => '1234'}.merge(attribs)
    end

    it 'should redirect to home page if invite_link is invalid' do
      InviteLink.should_receive(:find_by_unique_id).with('1234').once.and_return(nil)

      do_get
      flash[:error].should == 'Invite link is not found!'
      response.should redirect_to(root_url)
    end

    it 'should redirect to signup page and store location in session if not already logged in' do
      InviteLink.should_receive(:find_by_unique_id).with('1234').once.and_return(@invite_link)
      @invite_link.should_receive(:resource).with.once.and_return(@argument)

      do_get
      flash[:notice].should == "Please login/signup to join the argument"
      session[:unique_code].should == '1234'
      response.should redirect_to(signup_url)
    end

    it 'should add the user into the list of joined uses of the resource/debate' do
      InviteLink.should_receive(:find_by_unique_id).with('1234').once.and_return(@invite_link)
      @invite_link.should_receive(:resource).with.once.and_return(@argument)
      @invite_link.should_receive(:connect!).and_return(true)

      login_as(:quentin)
      do_get
      flash[:notice].should == 'You successfully joined the argument'
      session[:unique_code].should be_nil
      response.should redirect_to(argument_path(@argument))
    end
  end

  it 'handle POST /arguments/1/relations' do
    @debate   = mock_debate
    @argument  = mock_argument(
      :debate => @debate, :argument_type => 'pro', :negates_parent? => true,
      :bg_color => 0, :cascaded_score => '2.3', :v => '2', :relation_to_thumb => 'pro',
      :argument_links => [], :video => nil, :draft? => false, :user => @user, :author => @user,
      :full_title => '', :parent_id => nil, :can_be_modified_by? => true
    )
    @arguments = [@argument]
    Debate.stub!(:find).and_return(@debate)
    Argument.stub!(:find).and_return(@argument)
    @argument.stub!(:owner?).and_return(true)
    @argument.stub!(:immutable?).and_return(false)
    @debate.stub!(:arguments).and_return(@arguments)
    @debate.stub!(:is_freezed).and_return(false)

    @argument.should_receive(:relations).with('3').once.and_return(@arguments)
    post :relations, {:id => @argument.id, :relation_type => 3}
    response.should be_success
  end

  describe 'handles POST /arguments/1/duplicate_argument' do
    before(:each) do
      @sim_arg  = mock_model(SimilarArgument, :identification_hash => 'xyz')
      @argument = mock_argument
      Argument.stub!(:find).and_return(@argument)
    end

    it 'should redirect when not logged in' do
      SimilarArgument.should_not_receive(:find_or_create_record)
      post :duplicate_argument, {:id => 1}
      response.should redirect_to(new_session_path)
    end

    it 'should duplicate_argument when logged in' do
      login_as(:quentin)
      SimilarArgument.should_receive(:find_or_create_record).with(@argument).once.and_return(@sim_arg)

      post :duplicate_argument, {:id => 1}
      response.should be_success
      response.body.should == 'xyz'
    end
  end

  describe 'handles POST /debates/1/arguments/1/similar_argument' do
    before(:each) do
      @user = mock_user
      @debate = mock_debate(:id => 1)
      @argument_parent = mock_argument(:debate => @debate)
      Argument.stub!(:find).and_return(@argument_parent)
      Debate.stub!(:find).and_return(@debate)
      @user.stub!(:admin?).and_return(true)
      controller.stub!(:update_logins).and_return(true)
    end

    it 'should redirect when not logged in' do
      SimilarArgument.should_not_receive(:save_similar_argument)
      post :similar_argument, {:debate_id => 1, :parent_id => 1}
      response.should redirect_to(new_session_path)
    end

    it 'should create a similar_argument when logged in' do
      controller.stub!(:current_user).and_return(@user)
      SimilarArgument.should_receive(:save_similar_argument).with(@argument_parent, 'xyz', @user).and_return(true)

      login_as(:quentin)
      post :similar_argument, {:debate_id => 1, :parent_id => 1, :identification_hash => 'xyz'}
      response.should redirect_to(debate_path(@debate))
      flash[:notice].should == 'Successfully created the similar argument'
    end
  end
end
