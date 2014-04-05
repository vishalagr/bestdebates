require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::DefinitionsController do

  describe 'redirect to debates_url if user not admin_user' do
    before(:each) do
      login_as(:quentin)
    end

    after(:each) do
      response.should redirect_to(debates_url)
    end

    it 'GET  /admin/definitions'        do get  :index;               end
    it 'GET  /admin/definitions/1'      do get  :show, :id => 1;      end
    it 'POST /admin/definitions'        do post :create;              end
    it 'GET  /admin/definitions/new'    do get  :new;                 end
    it 'GET  /admin/definitions/1/edit' do get  :edit, :id => 1;      end
    it 'PUT  /admin/definitions/1'      do put  :update, :id => 1;    end
    it 'DELETE /admin/definitions/1'    do delete :destroy, :id => 1; end
  end

  describe 'for a logged in administrator' do
    before(:each) do
      @definition = mock_model(Definition, :id => 1)
      @request.env['HTTP_ACCEPT'] = 'text/html'
      login_as(:admin)
    end

    it 'handles PUT /admin/definitions/1' do
      Definition.should_receive(:find).with('1').once.and_return(@definition)
      @definition.should_receive(:update_attributes).once.with({'name'=>'DEF'}).and_return(true)
      post :update, :id => 1, :definition => {:name => 'DEF'}
      response.should redirect_to(admin_definitions_url)
    end

    it 'handles DELETE /admin/definitions/1' do
      Definition.should_receive(:find).with('1').once.and_return(@definition)
      @definition.should_receive(:destroy).with.once
      @request.env['HTTP_REFERER'] = '/'
      delete :destroy, :id => 1
      #flash[:notice].should == 'Definition was successfully deleted.'
      response.should redirect_to('/')
    end

    it 'handles GET /admin/definitions' do
      Definition.should_receive(:paginate).with(:page => '2', :per_page => 20).once.and_return([@definition])
      Definition.should_receive(:new).with.once.and_return(@definition)

      get :index, :page => 2
      assigns[:definitions].should == [@definition]
      assigns[:definition].should == @definition
      response.should be_success
    end

    it 'hanldes POST /admin/definitions' do
      Definition.should_receive(:create).with({'name'=>'DEF'}).once.and_return(@definition)
      @definition.should_receive(:errors).with.once.and_return([])

      post :create, :definition => {:name => 'DEF'}
      response.should redirect_to(admin_definitions_url)
      flash[:notice].should == 'Definition was successfully created.'
    end

    it 'hanldes POST /admin/definitions in json format' do
      Definition.should_receive(:create).with({'name'=>'DEF'}).once.and_return(@definition)
      @definition.should_receive(:errors).twice.and_return([])

      xhr :post, :create, :definition => {:name => 'DEF'}
      response.should have_rjs
    end
  end
end
