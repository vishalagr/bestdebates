require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe SponsorUser do

  before(:each) do
    @sponsor_user = Factory.build(:sponsor_user)
  end

  it "should be valid" do
    @sponsor_user.should be_valid
  end

  it "should require user" do
    @sponsor_user.user = nil
    @sponsor_user.should_not be_valid
    @sponsor_user.should have(1).error_on(:user)
  end

  it "should require sponsor" do
    @sponsor_user.sponsor = nil
    @sponsor_user.should_not be_valid
    @sponsor_user.should have(1).error_on(:sponsor)
  end

  it "should save_org_user" do
    # record already doens't exist
    lambda do
      @sponsor_user = SponsorUser.save_org_user(3, 5)
    end.should change(SponsorUser, :count).by(1)
    @sponsor_user.sponsor_id.should == 3
    @sponsor_user.user_id.should == 5

    # record already exists
    lambda do
      @sponsor_user = SponsorUser.save_org_user(3, 5)
    end.should_not change(SponsorUser, :count)
  end

end
