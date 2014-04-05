require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe InviteLinksController do

  include CustomFactory
  include MockFactory

  describe 'without logged in should redirect to login page' do
    after(:each) do
      response.should redirect_to(new_session_path)
    end

    it 'index' do
      get :index, :debate_id => 1
    end

    it 'new' do
      get :new, :debate_id => 1
    end

    it 'create' do
      post :create, :debate_id => 1
    end

    it 'invited_users' do
      post :invited_users, :debate_id => 1, :id => 1
    end
  end

  describe 'for a logged-in user' do
    
    before(:each) do
      @debate = mock_debate
      Debate.stub!(:find).and_return(@debate)

      @current_user = users(:quentin)
      controller.stub!(:current_user).and_return(@current_user)

      @invite_link  = mock_model(InviteLink, :id => 1, :display_title => 'TiTlE')
      login_as(:quentin)
    end

    it 'renders static 404 page if resource not found' do
      Argument.stub!(:find).and_raise(ActiveRecord::RecordNotFound)

      get :index, :argument_id => 1
      response.should render_template("#{RAILS_ROOT}/public/404.html")
    end

    it 'redirects to debate_url if user cannot invite' do
      controller.stub!(:can_edit_resource?).and_return(false)

      get :index, :debate_id => @debate.id
      flash[:error].should == "You don't have access to invite to this debate"
      response.should redirect_to(debate_url(@debate))
    end

    it 'handles GET /debates/1/invite_links' do
      controller.stub!(:can_edit_resource?).and_return(true)
      @debate.should_receive(:invite_links).with.once.and_return([@invite_link])

      get :index, :debate_id => @debate.id
      response.should be_success
      assigns[:invite_links].should == [@invite_link]
    end

    it 'handles GET /debates/1/invite_links/new' do
      controller.stub!(:can_edit_resource?).and_return(true)
      InviteLink.should_receive(:new).with.once.and_return(@invite_link)
      
      get :new, :debate_id => @debate.id
      response.should be_success
      assigns[:invite_link].should == @invite_link
    end

    it 'handles POST /debates/1/invite_links' do
      controller.stub!(:can_edit_resource?).and_return(true)
      InviteLink.should_receive(:create).once.and_return(@invite_link)

      post :create, :debate_id => @debate.id, :user_id => @current_user.id, :title => 'TiTlE'
      response.should be_success
      assigns[:invite_link].should == @invite_link
    end

    it 'handles POST /debates/1/invite_links/1/invited_users' do
      controller.stub!(:can_edit_resource?).and_return(true)
      InviteLink.should_receive(:find).with('1').once.and_return(@invite_link)
      @invite_link.should_receive(:invited_users).with.once.and_return([@current_user])

      post :invited_users, :debate_id => @debate.id, :id => @invite_link.id
      response.should be_success
      assigns[:invite_link].should == @invite_link
      assigns[:users].should == [@current_user]
    end
  end
end
