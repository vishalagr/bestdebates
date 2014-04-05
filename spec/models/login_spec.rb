require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe Login do

  before(:each) do
    @login = Factory.build(:login)
  end

  it "should be valid" do
    @login.should be_valid
  end

  it "should require name or user" do
    @login.user, @login.name = nil, nil
    @login.should have(1).error_on(:name)

    @login.user = Factory.create(:user)
    @login.should be_valid
  end

  it "should require loginid and duration" do
    @login.loginid = nil
    @login.should have(1).error_on(:loginid)

    @login.duration = nil
    @login.should have(1).error_on(:duration)
  end

  it "should have only numeric visits" do
    @login.visits = 12.34
    @login.should have(1).error_on(:visits)
  end

  it "should create login from session_id" do
    l = Login.create_from_session_id!('239429384', @login.attributes)
    l.new_record?.should_not be_true
    l.should be_valid
  end

  it "should visit!" do
    @login.save
    proc do
      @login.visit!
    end.should change(@login, :visits).by(1)
  end

end
