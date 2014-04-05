require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/debates/edit.html.erb" do
  include DebatesHelper
	include MockFactory
  
  before do
    @debate = mock_debate
    assigns[:debate] = @debate
		@category = mock_category
		assigns[:categories] = [@category]
  end

  it "should render edit form" do
    render "/debates/edit.html.erb"
    
    response.should have_tag("form[action=#{debate_path(@debate)}][method=post]") do
    end
  end
end


