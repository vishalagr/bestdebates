require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DebatesController do
  include CustomFactory
	include MockFactory
	
  describe "handling GET /debates" do

    before(:each) do
      @debate = mock_debate
      Debate.stub!(:find).and_return([@debate])
			Debate.stub!(:find_recent).and_return([@debate])
			Debate.stub!(:featured).and_return([@debate])
			Debate.stub!(:of_the_day).and_return([@debate])
      @debate.stub!(:public?).and_return(true)

			@category.stub!(:debates).and_return(Debate)
      Argument.stub!(:best_by_type_and_category).and_return(nil)
    end
  
    def do_get(attribs = {})
      get :index, {}.merge(attribs)
    end
  
    it 'should redirect to root_url if retired' do
      do_get(:retired => true)
      response.should redirect_to(root_url)
    end

    it "should be successful and set debates" do
      do_get
      response.should be_success
      response.should render_template('index')
      assigns[:debates].should == [@debate]
    end

		it "should find all featured debates and set the category" do
			@category = categories(:politics)
			@category.should_receive(:debates).once.and_return(Debate)
      Argument.should_receive(:best_by_type_and_category).twice.and_return(nil)
			Category.should_receive(:find).with(@category.id.to_s).and_return(@category)

			do_get(:category_id => @category.id)

      assigns[:debate_of_the_day].should == @debate
      assigns[:category].should == @category
      assigns[:best_pro_argument].should be_nil
		end

    describe 'should search debates based on parameters' do
      before(:each) do
        @category = categories(:politics)
      end

      it 'order by category name' do
        Debate.should_receive(:all).with(
          :include => [:category, :user],
          :conditions => ['debates.draft = ? AND debates.is_live = ? AND debates.category_id = ?', false, true, @category.id.to_s],
          :order => 'categories.name ASC'
        ).once.and_return([@debate])

        do_get(:c => 'category_id', :d => 'up', :category_id => @category.id)
      end

      it 'order by user login' do
        @user = users(:quentin)
        controller.stub!(:current_user).and_return(@user)
        @user.stub!(:public_and_owned_in).and_return([@debate])
        Debate.should_receive(:all).with(
          :include => [:category, :user],
          :conditions => ['debates.is_live = ? AND categories.name NOT LIKE ?', true, 'Practice Debates'],
          :order => 'users.login DESC'
        ).once.and_return([@debate])

        login_as(:quentin)
        do_get(:c => 'user_id', :d => 'down')
      end

      it 'fetch all debates if admin_user' do
        @user = users(:admin)
        controller.stub!(:current_user).and_return(@user)
        @user.stub!(:public_and_owned_in).and_return([@debate])
        Debate.should_receive(:all).once.and_return([@debate])

        login_as(:admin)
        do_get
      end

    end
  end

  describe "handling GET /debates.xml" do

    before(:each) do
      @debate  = mock_model(Debate, :id => 1)
      @debate.stub!(:public?).and_return(true)
      @debate.stub!(:select).and_return(@debate)
      @debate.stub!(:to_xml).and_return('XML')
      Debate.stub!(:all).and_return(@debate)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render the found debates as xml" do
      @debate.should_receive(:to_xml).and_return("XML")
      do_get
      assigns[:debates].should == @debate
      response.body.should == "XML"
    end
  end

  describe "handling GET /debates/1" do

    before(:each) do
      @debate = mock_debate
      @debate.stub!(:public?).and_return(true)
      @debate.stub!(:title).and_return('Debate Title')
      Debate.stub!(:first).and_return(@debate)

      @code = mock_model(Code)
      @invitation = mock_model(Invitation)
      Code.stub!(:find_by_unique_hash).and_return(@code)
      @code.stub!(:invitation).and_return(@invitation)
      @invitation.stub!(:connect!)
      @invitation.stub!(:resource).and_return(@debate)

      @user = users(:quentin)
    end
  
    def do_get(attribs = {})
      get :show, {:id => "1"}.merge(attribs)
    end

    it 'should redirect to debates_url if debate_show_permission_check fails' do
      @debate.stub!(:public?).and_return(false)
      @debate.stub!(:can_be_read_by?).and_return(false)
      do_get
      flash[:error].should == 'You have\'nt permission to read the debate'
      response.should redirect_to(debates_url)
    end

    it 'should redirect to root_url if invalid invitation_code is given' do
      do_get(:code => '')
      flash[:error].should == 'Invitation code is not found!'
      response.should redirect_to(root_url)
    end

    it 'should connect to an invitation' do
      @invitation.should_receive(:connect!).with(@user).once
      login_as(:quentin)

      do_get(:code => 'inv;code;inv;code;')
      session[:invitation_code].should be_nil
      flash[:notice].should == 'You successfully join the debate'
      response.should redirect_to(debate_url(@debate))
    end

    it 'should store_location of the invitation' do
      controller.should_receive(:store_location).and_return(true)

      do_get(:code => 'inv;code')
      session[:invitation_code].should == 'inv;code'
      response.should redirect_to(signup_url)
    end

    it "should be successful" do
      Debate.should_receive(:first).and_return(@debate)
      do_get
      response.should be_success
      response.should render_template('show')
      assigns[:debate].should equal(@debate)
    end
  end

  describe "handling GET /debates/1.xml" do

    before(:each) do
      @debate = mock_model(Debate, :to_xml => "XML")
      @debate.stub!(:public?).and_return(true)
      @debate.stub!(:title).and_return('Debate Title')
      Debate.stub!(:find).and_return(@debate)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end
  
    it "should be successful and render the found debate as xml" do
      @debate.should_receive(:to_xml).and_return("XML")
      do_get
      response.should be_success
      assigns[:debate].should == @debate
      response.body.should == "XML"
    end
  end

  describe "handling GET /debates/new when not logged in" do
		it "should require login" do
		  get :new
		  response.should redirect_to(new_session_path)
		end
  end
  
  describe "handling GET /debates/new" do

    before(:each) do
      @debate = mock_model(Debate)
      Debate.stub!(:new).and_return(@debate)
      login_as(:quentin)
    end
  
    def do_get
      get :new
    end

    it "should be successful" do
      Debate.should_receive(:new).and_return(@debate)
      @debate.should_not_receive(:save)
      do_get
      response.should be_success
      response.should render_template('new')
      assigns[:debate].should equal(@debate)
    end
  
  end

  describe "handling GET /debates/1/edit when not admin" do
    it "should redirect to /debates if non-admin user" do
      get :edit, :id => "1"
      response.should redirect_to(debates_path)
    end
  end
  
  describe "handling GET /debates/1/edit" do
    before(:each) do
      login_as(:admin)
      @debate = mock_model(Debate)
      @debate.stub!(:can_be_modified_by?).and_return(true)
      @debate.stub!(:is_freezed).and_return(false)
      @debate.stub!(:title).and_return('Debate Title')
      Debate.stub!(:find).and_return(@debate)
    end
  
    def do_get
      get :edit, :id => "1"
    end

    it "should be successful" do
      Debate.should_receive(:find).and_return(@debate)
      do_get
      response.should be_success
      response.should render_template('edit')
      assigns[:debate].should equal(@debate)
    end
  end
  
  describe "handling POST /debates when not logged in" do
    
    it "should require login" do
      post :create, :debate => {}
      response.should redirect_to(new_session_path)
    end
    
  end

  describe "handling POST /debates" do

    before(:each) do
      login_as(:quentin)
      @debate = mock_debate
      @debate.stub!(:set_status_from_buttons)
      @debate.stub!(:user=)
      Debate.stub!(:new).and_return(@debate)
    end
    
    describe "with successful save" do
  
      def do_post
        @debate.should_receive(:save).and_return(true)
        post :create, :debate => {}
      end
  
      it "should create a new debate" do
        Debate.should_receive(:new).with({}).and_return(@debate)
        do_post
        response.should redirect_to(debate_url(@debate))
      end

    end
    
    describe "with failed save" do

      def do_post
        @debate.should_receive(:save).and_return(false)
        post :create, :debate => {}
      end
			
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end

    describe "with cancelled save" do

      it 'should redirect to debates_url' do
        post :create, {:debate => {:category_id => 10}, 'cancel.x' => true}
        response.should redirect_to(debates_url(:category_id => 10))
      end

      it 'should redirect to debates_url' do
        post :create, {:debate => {}, 'cancel.x' => true}
        response.should redirect_to(root_url)
      end

    end

  end

  describe "handling PUT /debates/1 when not administrator" do
    
    it "should redirect to /debates" do
      @debate.stub!(:is_freezed).and_return(false)
      put :update, :id => '1'
      response.should redirect_to(debates_path)
    end
    
  end
  
  describe "handling PUT /debates/1" do

    before(:each) do
      login_as(:admin)
      @debate = mock_model(Debate, :to_param => "1")
      @debate.stub!(:can_be_modified_by?).and_return(true)
      @debate.stub!(:is_freezed).and_return(false)
      @debate.stub!(:set_status_from_buttons)
      Debate.stub!(:find).and_return(@debate)
    end
    
    describe "with successful update" do

      def do_put
        @debate.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the debate requested" do
        Debate.should_receive(:first).with({:conditions => ['id = ?', '1']}).and_return(@debate)
        do_put
      end

      it "should update the found debate" do
        do_put
        assigns(:debate).should equal(@debate)
        response.should redirect_to(debate_url("1"))
      end

    end
    
    describe "with failed update" do

			def do_put
        @debate.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end
			
      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end
  
  describe "handling DELETE /debates/1 when not administrator" do 
    
    it "should redirect to /debates" do
      delete :destroy, :id => '1'
      response.should redirect_to(debates_path)
    end
        
  end

  describe "handling DELETE /debates/1" do

    before(:each) do
      login_as(:admin)
      @debate = mock_model(Debate, :destroy => true)
      @debate.stub!(:can_be_modified_by?).and_return(true)
      @debate.stub!(:is_freezed).and_return(false)
      @debate.stub!(:retire!)
      Debate.stub!(:find).and_return(@debate)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end
		
    it "should find the debate requested" do
      Debate.should_receive(:first).with({:conditions => ['id = ?', '1']}).and_return(@debate)
      @debate.should_receive(:retire!)
      do_delete
      response.should redirect_to(debates_url)
    end
  
  end

  describe 'handle GET /debates/1/rss/deep/2.xml' do

    after(:each) do
      response.should be_success
    end

    def do_rss(attribs = {})
      get :rss, {:id => 1, :deep => 2}.merge(attribs)
    end

    it 'should render successfully' do
      do_rss
    end

    it 'should set depth variable' do
      do_rss(:deep => 10)
      assigns[:deep].should == 10

      do_rss(:deep => '233')
      assigns[:deep].should == 233
    end
  end

  describe 'handle POST /debates/1/bookmark' do
    before(:each) do
      @debate = mock_debate
      Debate.stub!(:first).and_return(@debate)
      @debate.stub!(:bookmark_by).and_return(true)
    end

    def do_bookmark
      xhr :post, :bookmark, :id => 1
    end

    it 'should redirect to login page if not logged_in' do
      @user.should_not_receive(:bookmark)
      do_bookmark
    end

    it 'should bookmark the debate' do
      @user = users(:quentin)
      controller.stub!(:current_user).and_return(@user)
      login_as(:quentin)

      @user.should_receive(:bookmark).with(@debate).once
      do_bookmark
    end
  end

  describe 'handle POST /debates/1/unbookmark' do
    before(:each) do
      @debate = mock_debate
      Debate.stub!(:first).and_return(@debate)
      @debate.stub!(:bookmark_by).and_return(false)
    end

    def do_unbookmark
      xhr :post, :unbookmark, :id => 1
    end

    it 'should redirect to login page if not logged_in' do
      @user.should_not_receive(:unbookmark)
      do_unbookmark
    end

    it 'should unbookmark the debate' do
      @user = users(:quentin)
      controller.stub!(:current_user).and_return(@user)
      login_as(:quentin)

      @user.should_receive(:unbookmark).with(@debate).once
      do_unbookmark
    end
  end

  describe 'handle PUT /debates/1/add_tag' do
    before(:each) do
      @debate = mock_debate
      Debate.stub!(:first).and_return(@debate)
      @debate.stub!(:bookmark_by).and_return(false)
      @debate.stub!(:is_freezed).and_return(false)

      controller.stub!(:can_edit_debate?).and_return(true)
    end

    def do_add_tag(attribs = {})
      post :add_tag, {:id => 1}.merge(attribs)
    end

    describe 'should redirect to debates_url if can\'t edit debate' do
      before(:each) do
        controller.stub!(:can_edit_debate?).and_return(false)
      end

      after(:each) do
        response.should redirect_to(debates_url)
        flash[:error].should == 'You have\'nt access to edit debate!'
      end

      it 'if not logged in' do
        do_add_tag
      end

      it 'if logged in but can\'t edit debate' do
        login_as(:quentin)
        do_add_tag
      end
    end

    it 'redirect to debate page if practice_debate?' do
      @debate.should_receive(:practice_debate?).once.and_return(true)
      do_add_tag
      response.should redirect_to(debate_url(@debate))
      flash[:error].should == 'The debates\' tags in "Practice Debates" category can\'t be changed!'
    end

    describe 'saves tag_list' do
      before(:each) do
        @tag_list = mock_model(TagList)
        @debate.should_receive(:practice_debate?).once.and_return(false)
        @debate.should_receive(:tag_list).once.and_return(@tag_list)
        @tag_list.should_receive(:add).with('tag_1, tag_2'.split(',')).once
      end

      it 'saves tag_list successfully' do
        @debate.should_receive(:save).once.and_return(true)
        do_add_tag(:tag => 'tag_1, tag_2')
        response.should redirect_to(debate_url(@debate))
        flash[:notice].should == 'The tags was successfully added.'
      end

      it 'does not save tag_list' do
        @debate.should_receive(:save).once.and_return(false)
        do_add_tag(:tag => 'tag_1, tag_2')
        response.should redirect_to(debate_url(@debate))
        flash[:error].should == 'Can\'t add the tag'
      end
    end
  end

  it 'handle POST /debates/1/search' do
    @user = mock_user(:admin? => false)
    @debate = mock_debate(
      :humanized_rating => '2.3', :is_freezed => false, :is_live? => true,
      :draft? => false, :priv? => false, :author => @user, :can_be_modified_by? => true
    )
    controller.stub!(:current_user).and_return(@user)

    Debate.should_receive(:sphinx_search).with('1', 'xyz', @user).and_return([@debate])
    post :search, {:category_id => 1, :query => 'xyz'}
    assigns[:debates].should == [@debate]
    response.should be_success
  end

  describe 'handle POST /debates/1/report_offensive' do
    before(:each) do
			@debate = mock_debate
      @user = mock_user
      Debate.stub!(:find).and_return(@debate)
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
      Mailers::Debate.should_receive(:deliver_offensive_report).with(@debate, @user).once.and_return(true)
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
      @user = mock_user

			@debate.stub!(:public?).and_return(true)
      Debate.stub!(:find).and_return(@debate)
      controller.stub!(:featured_debates).and_return([])
      controller.stub!(:update_logins).and_return(true)
      controller.stub!(:edit_permission_check).and_return(true)
      login_as(:quentin)

      @flash_error = 'The debate you are trying to edit is freezed.'
    end

    it 'handle GET /debates/1/edit for an unfreezed argument' do
      @debate.stub!(:can_be_modified_by?).and_return(true)
      @debate.should_receive(:is_freezed).and_return(false)
      controller.stub!(:edit).and_return(true)

      get :edit, :id => 1
    end

    it 'handles :edit, :update' do
      @debate.should_receive(:is_freezed).and_return(true)

      post :edit, :id => 1
      response.should redirect_to(debate_path(@debate))
      flash[:error].should == @flash_error
    end

    it 'handles tab actions and :add_tag' do
      @debate.should_receive(:is_freezed).and_return(true)
      @debate.should_not_receive(:practice_debate?)  # in add_tag method

      post :add_tag, :id => 1
      response.should have_rjs
    end
  end
end
