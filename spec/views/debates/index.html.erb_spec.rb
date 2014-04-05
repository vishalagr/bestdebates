require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/debates/index.html.erb" do
  include DebatesHelper
	include MockFactory
  
  before(:each) do
    debate_98 = create_debate(valid_debate_attributes.merge(:title => 'test 1', 
																													  :updated_at => 1.hour.ago))
    debate_99 = create_debate(valid_debate_attributes.merge(:title => 'test 2', 
																														:updated_at => 1.day.ago))

    assigns[:debates] = [debate_98, debate_99]
  end

  it "should render list of debates" do
    render "/debates/index.html.erb"
  end
end

