require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Mailers::Debate do
	
  include CustomFactory
  include MockFactory

  before(:all) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    @deliveries = ActionMailer::Base.deliveries = []
  end

  before(:each) do
    @invitation = Factory.create(:invitation)
  end

  it "should setup email" do
    mailer = Mailers::Debate.create_invitation(@invitation.invitor, @invitation.resource, @invitation)
    mailer.from.first.should == 'info@bestdebates.com'
    mailer.subject.should =~ /^BestDebates.com: /
    #mailer.sent_on.should < Time.now

    mailer.to.include?(@invitation.user.email.to_s).should be_true
  end

  it "should deliver invitation" do
    mailer = nil
    lambda {
      mailer = Mailers::Debate.deliver_invitation(@invitation.invitor, @invitation.resource, @invitation)
    }.should change(@deliveries, :size).by(1)
    mailer.subject.should =~ /Your has been invited to see debate '#{@invitation.resource.title}'$/
  end

  it "should deliver send_email" do
    self.stub!(:setup_email)
    @debate   = mock_debate
    @argument = mock_argument(:debate => @debate, :children => [])

    mailer = nil
    lambda {
      mailer = Mailers::Debate.deliver_send_email(@argument, 5, 'someone@bestdebates.com')
    }.should change(@deliveries, :size).by(1)

    mailer.subject.should =~ /#{@argument.title}/
    mailer.body.should =~ /debates\/#{@debate.id}/
    mailer.to.include?('someone@bestdebates.com').should be_true
  end

  it "should deliver offensive_report" do
    self.stub!(:setup_email)
    @debate   = mock_debate
    @user     = mock_user

    mailer = nil
    lambda {
      mailer = Mailers::Debate.deliver_offensive_report(@debate, @user)
    }.should change(@deliveries, :size).by(1)

    mailer.from.first.should == 'offensive@bestdebates.com'
    mailer.subject.should =~ /Offensive Argument\/Debate$/
  end
end

