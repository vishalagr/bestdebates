require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::CategoriesController do

  include MockFactory

  describe 'redirect to debates_url if user not admin_user' do
    before(:each) do
      login_as(:quentin)
    end

    after(:each) do
      response.should redirect_to(debates_url)
    end

    it 'GET  /admin/categories'               do get  :index;               end
    it 'POST /admin/categories'               do post :create;              end
    it 'PUT  /admin/categories/1'             do put  :update, :id => 1;    end
    it 'DELETE /admin/categories/1'           do delete :destroy, :id => 1; end
    it 'GET  /admin/categories/debate_of_day' do get :debate_of_day;        end
    it 'POST /admin/categories/debate_of_day' do post :debate_of_day;       end
  end

  describe 'for a logged in admin' do
    before(:each) do
      @category = mock_category(:id => 1)
      login_as(:admin)
    end

    it 'handles GET /admin/categories' do
      Category.should_receive(:new).with.once.and_return(@category)

      get :index
      assigns[:category].should == @category
      response.should be_success
    end

    describe 'handles POST /admin/categories' do
      before(:each) do
        Category.should_receive(:new).with({'name'=>'newname'}).once.and_return(@category)
      end

      after(:each) do
        response.should redirect_to(admin_categories_url)
      end

      it 'creates successfully' do
        @category.should_receive(:save).with.once.and_return(true)
        post :create, {:category => {:name => 'newname'}}
        flash[:notice].should == 'New category was successfully created!'
      end

      it 'doesn\'t create category' do
        @category.should_receive(:save).with.once.and_return(false)
        post :create, {:category => {:name => 'newname'}}
        flash[:error].should == 'Error in creating new category. All attributes must be filled!'
      end
    end

    describe 'handles PUT /admin/categories/1' do
      before(:all) do
        @debates = mock('Array of Debates')
      end

      it 'if categories list is empty' do
        put :update, :id => 1
        response.should redirect_to(admin_categories_url)
        flash[:error].should == 'Categories list is empty'
      end

      it 'if categories list is given' do
        Category.should_receive(:find).with(['1', '2']).once.and_return([@category])
        @category.should_receive(:debates).with.once.and_return(@debates)
        @debates.should_receive(:update_all).with(['is_live = ?', 2])

        put :update, :id => 1, :ids => {'1' => '2', '2' => '3'}
        response.should redirect_to(admin_categories_url)
        flash[:notice].should == 'Debates\' status was updated!'
      end
    end

    it 'handles DELETE /admin/categories/1' do
      @debates = mock('Array of Debates')
      @debate  = mock_debate

      Category.should_receive(:find).with('1').once.and_return(@category)
      @category.should_receive(:debates).with.once.and_return(@debates)
      @debates.should_receive(:each).and_return(@debate)
      @category.should_receive(:destroy).with.once.and_return(true)

      delete :destroy, :id => 1
      flash[:notice].should == 'all debates of the destroyed category was retired!'
      response.should redirect_to(admin_categories_url)
    end

    it 'handles GET /admin/category/debate_of_day' do
      Debate.should_not_receive(:update_all)
      get :debate_of_day
    end

    it 'handles POST /admin/category/debate_of_day' do
      Debate.should_receive(:update_all).twice.and_return(true)
      post :debate_of_day, :category_id => 1
      flash[:notice].should == 'Your Debate of the day Has Been saved.'
    end
  end
end
