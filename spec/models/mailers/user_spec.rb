require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Mailers::User do
	
  before(:all) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    @deliveries = ActionMailer::Base.deliveries = []
  end

  before(:each) do
    @user = Factory.create(:user)
  end

  it "should deliver signup_notification" do
    lambda {
      @mailer = Mailers::User.deliver_signup_notification(@user)
    }.should change(@deliveries, :size).by(1)
    @mailer.subject.should =~ /Your account has been activated!$/
  end

  it "should deliver activation" do
    lambda {
      @mailer = Mailers::User.deliver_activation(@user)
    }.should change(@deliveries, :size).by(1)
    @mailer.subject.should =~ /Please activate your new account$/
  end

  it "should deliver password_reset" do
    lambda {
      @mailer = Mailers::User.deliver_password_reset(@user)
    }.should change(@deliveries, :size).by(1)
    @mailer.subject.should =~ /Your password has been reset$/
  end

end
