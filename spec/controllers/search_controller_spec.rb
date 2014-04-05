require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchController do

  before(:all) do
    @search_result = mock_model(SearchResult)
  end

  #Delete these examples and add some real ones
  it "should use SearchController" do
    controller.should be_an_instance_of(SearchController)
  end


  describe "GET 'index'" do
    after(:each) do
      response.should be_success
    end

    it "should get empty set when search_term is blank" do
      get :index, {:search_term => nil}
      assigns[:results].should == []
    end

    it 'should get results when a non-empty search_term is given' do
      SearchResult.should_receive(:find).with('dummy_title', :false).once
      get :index, {:search_term => 'dummy_title'}
    end

    it 'should get results when tag is given' do
      SearchResult.should_receive(:find_args_with_tag).with('tag_name').once.and_return([])
      get :index, {:tag => 'tag_name'}
      assigns[:show_search_title].should be_true
      assigns[:results].should == []
    end
  end

  describe 'handles create and update' do
    before(:all) do
      @result = SearchResult.new
    end

    before(:each) do
      SearchResult.should_receive(:find).with('xyz', :false).once.and_return([@result])
    end

    after(:each) do
      assigns[:categories].should == []
      assigns[:results].should == [@result]
      response.should render_template(:index)
    end

    it 'creates' do
      put :create, :search_result => {:search => 'xyz'}
    end

    it 'updates' do
      put :update, :id => 1, :search_result => {:search => 'xyz'}
    end
  end
end
