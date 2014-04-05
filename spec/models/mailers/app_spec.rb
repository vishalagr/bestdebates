require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Mailers::App do
	
  before(:all) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    @deliveries = ActionMailer::Base.deliveries = []
  end
	
  it "should redeploy" do
    lambda {
      @app = Mailers::App.deliver_redeploy
    }.should change(@deliveries, :size).by(1)

    @app.subject.should =~ /BestDebates redeployed/
    @app.body.should =~ /BestDebates redeployed/
    @app.to.size.should >= 1
  end

end
