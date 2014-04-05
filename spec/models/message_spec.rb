require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Message do
	
  before(:each) do
    @message = Factory.build(:message)
  end

  it "should be valid" do
    @message.should be_valid
  end

  it "should require a body" do
    @message.body = nil
    @message.should have(1).error_on(:body)
  end

end
