require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::DebatesController do

  include MockFactory

  describe 'handle GET /admin/debates/1/unretire' do

    it 'should redirect to debates_url if not admin' do
      login_as(:quentin)
      get :unretire, :id => 1
      response.should redirect_to(debates_url)
    end

    it 'unretires a debate' do
      @debate = mock_debate
      Debate.stub!(:first).and_return(@debate)
      @debate.should_receive(:live!).with.once.and_return(true)

      login_as(:admin)
      get :unretire, :id => 1
      
      response.should redirect_to(debate_url(@debate))
      flash[:notice].should == 'Debate was successfully unretired!'
    end

  end

  describe 'handle POST /admin/debates/manage' do

    it 'should redirect to debates_url if not admin' do
      login_as(:quentin)
      post :manage
      response.should redirect_to(debates_url)
    end

    def do_manage(attribs = {})
      post :manage, {:debates => {:id => [1, 2]}, :category_id => 3, :commit => 'Retire'}.merge(attribs)
    end

    describe 'removes debates' do
      before(:each) do
        @debate = mock_debate
        Debate.should_receive(:find).with([1, 2]).once.and_return([@debate])
        login_as(:admin)
      end
      
      after(:each) do
        response.should redirect_to(debates_url(:category_id => 3))
      end

      it 'retires debates' do
        @debate.should_receive(:retire!).with.once.and_return(true)
        do_manage(:commit => 'Retire')
        flash[:notice].should == 'Selected debates were retired!'
      end

      it 'deletes debates' do
        @debate.should_receive(:destroy).with.once.and_return(true)
        do_manage(:commit => 'Delete')
        flash[:notice].should == 'Selected debates were deleted!'
      end

      it 'freezes debates' do
        @debate.should_receive(:freeze).with.once.and_return(true)
        do_manage(:commit => 'Freeze')
        flash[:notice].should == 'Selected debates were freezed!'
      end

      it 'unfreezes debates' do
        @debate.should_receive(:unfreeze).with.once.and_return(true)
        do_manage(:commit => 'Unfreeze')
        flash[:notice].should == 'Selected debates were unfreezed!'
      end
    end

    it 'gives error message when no ids are given' do
      login_as(:admin)
      do_manage(:debates => nil)
      
      response.should redirect_to(debates_url(:category_id => 3))
      flash[:error].should == 'No debates selected!'
    end

  end
end
