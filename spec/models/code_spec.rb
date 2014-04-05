require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Code do
	
  before(:each) do
    @code = Factory.build(:code)
  end

  it "should be valid" do
    @code.should be_valid
  end

  it "should require an invitation" do
    @code.invitation = nil
    @code.should have(1).error_on(:invitation_id)
  end

  it "should have unique hash" do
    @code.save
    new_code = Factory.build(:code, :unique_hash => @code.unique_hash)
    new_code.should have(1).error_on(:unique_hash)
  end

  it "should hash unique_hash after_initialize" do
    @code.send(:after_initialize).should_not be_nil
  end

end


