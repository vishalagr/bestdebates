require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::GroupsController do
  before(:each) do
    @user = mock_user
  end

  describe 'redirect to debates_url if user not admin_user' do
    before(:each) do
      login_as(:quentin)
    end

    after(:each) do
      response.should redirect_to(debates_url)
    end

    it 'GET  /admin/groups'     do get :index;                                       end
    it 'GET  /admin/groups/1'   do get :show, :id => 1;                              end
    it 'GET  /admin/groups/new' do get :new;                                         end
    it 'POST /admin/groups'     do post :create, {:group => {:name => 'new_group'}}; end
  end

  describe 'handle GET /admin/groups/1' do
    it 'responds successfully' do
      @group = mock_model(Group, :id => 1)
      Group.should_receive(:find).with('1').once.and_return(@group)
      @group.should_receive(:members).and_return(@user)
      @user.should_receive(:all).and_return([@user])
      login_as(:admin)

      get :show, :id => 1
      response.should be_success
      assigns[:group].should == @group
      assigns[:members].should == [@user]
    end

    it 'responds for invalid group id' do
      login_as(:admin)
      get :show, :id => 123
      response.body.should == 'No item found'
    end
  end

  describe 'handle POST /admin/groups' do
    it 'responds successfully' do
      @group = mock_model(Group, :id => 1)
      @group.stub!(:save).and_return(true)
      controller.stub!(:current_user).and_return(@user)
      controller.stub!(:update_logins).and_return(true)
      @user.stub!(:admin?).and_return(true)
      Group.should_receive(:new).with({'name' => 'newname'}).once.and_return(@group)
      @group.stub!(:creator=).with(@user).and_return(@user)
      login_as(:admin)

      post :create, :group => {:name => 'newname'}
      response.should be_redirect
      assigns[:group].should == @group
    end
  end
end
