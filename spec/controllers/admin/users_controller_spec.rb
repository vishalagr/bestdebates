require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::UsersController do

  before(:each) do
    @admin_user = users(:admin)
    @user = mock_user
    @user.stub!(:admin?).and_return(false)
    controller.stub!(:featured_debates)
    controller.stub!(:update_logins)
  end

  describe 'handle GET /admin/users and POST /admin/users/search' do
    before(:each) do
      @search_results = [mock_model(SearchResult)]
    end

    def get_index(attribs = {})
      get :index
    end

    it 'redirect to debates_url if not logged_in or not admin_user' do
      get_index
      response.should redirect_to(debates_url)

      login_as(:quentin)
      get_index
      response.should redirect_to(debates_url)
    end

    describe 'handle index and search' do
      before(:each) do
        @search_results.should_receive(:find).with.once.and_return([@user])
        login_as(:admin)
      end

      after(:each) do
        response.should be_success
        assigns[:search_results].should == @search_results
        assigns[:users].should == [@user]
      end

      it 'renders successfully' do
        params = {'controller'=>'admin/users', 'action'=>'index'}
        Admin::UsersSearch.should_receive(:new).with(params).once.and_return(@search_results)
        get_index
      end

      it 'handles POST /admin/users/search' do
        params = {'controller'=>'admin/users', 'action'=>'search'}
        Admin::UsersSearch.should_receive(:new).with(params).once.and_return(@search_results)
        post :search
        response.should render_template(:index)
      end
    end
  end


  describe 'handle GET /admin/users/1/edit' do
    before(:each) do
      User.stub!(:find_by_id).and_return(@user)
    end

    def get_edit(attribs = {})
      get :edit, {:id => 1}.merge(attribs)
    end

    it 'redirect to debates_url if not logged_in' do
      get_edit
      response.should redirect_to(debates_url)
    end

    it 'redirect to debates_url if not admin_user' do
      controller.stub!(:current_user).and_return(@user)
      login_as(:quentin)
      get_edit
      response.should redirect_to(debates_url)
    end

    it 'should get user if admin_user' do
      controller.stub!(:current_user).and_return(@admin_user)
      login_as(:admin)
      get_edit
      response.should render_template(:edit)
      assigns[:user].should == @user
    end

    it 'should get user in xml' do
      controller.stub!(:current_user).and_return(@admin_user)
      @user.should_receive(:to_xml).with().once.and_return('custom xml')
      login_as(:admin)

      @request.env['HTTP_ACCEPT'] = 'application/xml'
      get_edit
      response.body.should == 'custom xml'
    end
  end


  describe 'handle PUT /admin/users/1' do
    before(:each) do
      User.stub!(:find_by_id).and_return(@user)
    end

    def do_update(attribs = {})
      get :update, {:id => 1, :user => {}}.merge(attribs)
    end

    it 'redirect to debates_url if not logged_in' do
      do_update
      response.should redirect_to(debates_url)
    end

    it 'redirect to debates_url if not admin_user' do
      login_as(:quentin)
      do_update
      response.should redirect_to(debates_url)
    end

    describe 'should update user' do
      before(:each) do
        login_as(:admin)
        controller.stub!(:admin_required).and_return(true)
      end

      after(:each) do
        assigns[:user].should == @user
      end

      it 'renders html after successful update' do
        @user.should_receive(:update_attributes).with({'name' => 'New Name'}).and_return(true)
        do_update(:user => {:name => 'New Name'})
        response.should render_template(:edit)
        flash[:notice].should == 'Your changes have been saved'
      end

      it 'renders xml after successful update' do
        @user.should_receive(:update_attributes).with({'name' => 'New Name'}).and_return(true)
        @user.should_receive(:to_xml).with.once.and_return('custom xml')

        @request.env['HTTP_ACCEPT'] = 'application/xml'
        do_update(:user => {:name => 'New Name'})
        response.body.should == 'custom xml'
        flash[:notice].should == 'Your changes have been saved'
      end

      it 'renders html after unsuccessful update' do
        @user.should_receive(:update_attributes).with({'name' => 'New Name'}).and_return(false)
        do_update(:user => {:name => 'New Name'})
        response.should render_template(:edit)
        flash[:notice].should_not == 'Your changes have been saved'
      end
    end
  end


  describe 'handle GET /admin/users/1/drop' do
    before(:each) do
      User.stub!(:find_by_id).and_return(@user)
    end

    def do_drop(attribs = {})
      get :drop, {:id => 1}
    end

    it 'redirect to debates_url if not logged_in' do
      do_drop
      response.should redirect_to(debates_url)
    end

    it 'redirect to debates_url if not admin_user' do
      login_as(:quentin)
      do_drop
      response.should redirect_to(debates_url)
    end

    it 'drops a user successfully' do
      login_as(:admin)
      controller.stub!(:admin_required).and_return(true)
      @user.should_receive(:delete!).with.once.and_return(true)
      do_drop
      response.should redirect_to(admin_users_path)
    end
  end


  describe 'handle GET /admin/users/1/purge' do
    before(:each) do
      User.stub!(:find_by_id).and_return(@user)
    end

    def do_purge(attribs = {})
      get :purge, {:id => 1}
    end

    it 'redirect to debates_url if not logged_in' do
      do_purge
      response.should redirect_to(debates_url)
    end

    it 'redirect to debates_url if not admin_user' do
      login_as(:quentin)
      do_purge
      response.should redirect_to(debates_url)
    end

    it 'purges a user successfully' do
      login_as(:admin)
      controller.stub!(:admin_required).and_return(true)
      @user.should_receive(:destroy).with.once.and_return(true)
      do_purge
      response.should redirect_to(admin_users_path)
    end
  end

end
