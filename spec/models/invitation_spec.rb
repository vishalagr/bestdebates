require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Invitation do
	
  before(:each) do
    @invitation = Factory.build(:invitation)
  end

  it "should be valid" do
    @invitation.should be_valid
  end

  it "should require resource" do
    @invitation.resource = nil
    @invitation.should have(1).error_on(:resource)
  end

  it "should require resource_type" do
    @invitation.resource_type = nil
    @invitation.should have(1).error_on(:resource_type)
  end

  it "should require invitor_id" do
    @invitation.invitor = nil
    @invitation.should have(1).error_on(:invitor_id)
  end

  it "should require email to be in proper format" do
    @invitation.user = nil

    @invitation.email = nil
    @invitation.should have(1).error_on(:email)

    @invitation.email = 'lkjsldf'
    @invitation.should have(1).error_on(:email)

    @invitation.email = 'some@something.org'
    @invitation.should be_valid
  end

  it "should get message_body" do
    @invitation.message_body == @invitation.message.body

    @invitation.message = nil
    @invitation.message_body == 'No message provided'
  end

  it "should get visited?" do
    @invitation.last_visited = nil
    @invitation.visited?.should == false

    @invitation.last_visited = Time.now
    @invitation.visited?.should == true
  end

  it "should get visited" do
    @invitation.last_visited = nil
    @invitation.visited
    @invitation.last_visited.should_not be_nil
  end

  it "should get visited!" do
    @invitation.last_visited = nil
    @invitation.visited!
    @invitation.new_record?.should be_false
    @invitation.last_visited.should_not be_nil
  end

  it "should get guest?" do
    @invitation.email, @invitation.user = 'someone@something.com', nil
    @invitation.guest?.should be_true
  end

  it "should connect! to a user" do
    lambda { @invitation.connect!(nil) }.should raise_error(ActiveRecord::RecordNotFound)
    proc { @invitation.connect!(@invitation.invitor) }.should change(@invitation.resource.joined_users, :count).by(1)
  end

  it "should invite groups" do
  end
end
