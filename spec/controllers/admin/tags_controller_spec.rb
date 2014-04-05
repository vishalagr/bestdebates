require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::TagsController do

  describe 'redirect to debates_url if user not admin_user' do
    before(:each) do
      login_as(:quentin)
    end

    after(:each) do
      response.should redirect_to(debates_url)
    end

    it 'GET  /admin/tags'        do get  :index;               end
    it 'GET  /admin/tags/1'      do get  :show, :id => 1;      end
    it 'POST /admin/tags'        do post :create;              end
    it 'GET  /admin/tags/new'    do get  :new;                 end
    it 'GET  /admin/tags/1/edit' do get  :edit, :id => 1;      end
    it 'PUT  /admin/tags/1'      do put  :update, :id => 1;    end
    it 'DELETE /admin/tags/1'    do delete :destroy, :id => 1; end
    it 'GET  /admin/tags/cloud'  do get  :cloud;               end
  end

  describe 'for logged_in admin' do
    before(:each) do
      @tag = mock_model(Tag, :id => 1)
      login_as(:admin)
    end

    it 'handles GET /admin/tags' do
      Tag.should_receive(:new).with.once.and_return(@tag)
      Tag.should_receive(:paginate).with({ :page => 1, :per_page => 24, :order => "name DESC" }).and_return([@tag])

      # :index action
      get :index, {:order_by => 'name', :order_name => 'desc'}
      assigns[:order_by].should == 'name'
      assigns[:order_name].should == 'DESC'
      assigns[:order_popularity].should == 'ASC'
      assigns[:tag].should == @tag
      assigns[:tags].should == [@tag]
    end

    it 'handles GET /admin/tags/cloud' do
      Tag.should_receive(:new).with.once.and_return(@tag)

      get :cloud, {:order_by => 'popularity', :order_name => 'asc'}
      assigns[:tag].should == @tag
    end

    it 'hanldes DELETE /admin/tags/1' do
      Tag.should_receive(:find).with('1').once.and_return(@tag)
      @tag.should_receive(:destroy).with.once.and_return(true)

      delete :destroy, :id => 1
      flash[:notice].should == 'Tag was deleted'
      response.should redirect_to(admin_tag_path)
    end

  end

end
