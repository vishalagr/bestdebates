require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArgumentLink do
	
  before(:each) do
    @argument_link = Factory.build(:argument_link)
  end

  it "should be valid" do
    @argument_link.should be_valid
  end

  it "should require a url" do
    @argument_link.url = nil
    @argument_link.should have(1).error_on(:url)
  end

  it "should normalize links" do
    @argument_link.url = 'www.bestdebates.com'
    @argument_link.normalize_uri.should == 'http://www.bestdebates.com/'

    @argument_link.url = 'http://www.bestdebates.com'
    @argument_link.normalize_uri.should == 'http://www.bestdebates.com/'

    @argument_link.url = nil
    @argument_link.normalize_uri.should == nil
  end

  it "should normalize the url before saving" do
    @argument_link.url = 'www.bestdebates.com'
    @argument_link.save
    @argument_link.url.should == 'http://www.bestdebates.com/'
  end

end
