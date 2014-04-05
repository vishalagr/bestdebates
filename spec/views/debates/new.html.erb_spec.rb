require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/debates/new.html.erb" do
  include DebatesHelper
	include MockFactory
  
  before(:each) do
    @debate = Debate.new
    @debate.stub!(:new_record?).and_return(true)
		@debate.stub!(:category_id).and_return(nil)
    assigns[:debate] = @debate
		assigns[:categories] = [mock_category]
  end

  it "should render new form" do
    render "/debates/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", debates_path) do
    end
  end
end


