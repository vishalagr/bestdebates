require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserResource do
	
  before(:each) do
    @user_resource = Factory.build(:user_resource)
  end

  it "should be valid" do
    @user_resource.should be_valid
  end

  it "should require user_id" do
    @user_resource.user_id = nil
    @user_resource.should have(1).error_on(:user_id)
  end

  it "should require resource" do
    @user_resource.resource = nil
    @user_resource.should have(1).error_on(:resource)
  end

  it "should require resource_type" do
    @user_resource.resource_type = nil
    @user_resource.should have(1).error_on(:resource_type)
  end

  it "should find_by_user and find_by_resource" do
    @user_resource.save

    UserResource.find_by_user(@user_resource.user).should == @user_resource
    UserResource.find_by_resource_id(@user_resource.resource.id).should == @user_resource
  end

  it "should validate_is_writable" do
    @user_resource.is_writable = nil
    @user_resource.send(:validate_is_writable)
    #@user_resource.should have(1).error_on(:is_writable)
  end

end
