require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContentFilter do
	
	def filtered(text)
		ContentFilter.filter(text)
	end
	
	it "should allow permitted tags" do
		text1 = "Some plain old HTML-free text."
		filtered(text1).should == text1
		
		text2 = "<p>Here's to <b>you</b>!</p><p>For everything you do,<br/> this <i>bud</i>'s for you. Need a lighter?</p>"
		filtered(text2).should == text2
	end
	
	it "should handle malformed HTML gracefully" do
		text1 = "<p>Whoops! Forgot to end this tag."
		filtered(text1).should == text1
   
    text2 = "<p>oh my, ending a p tag with br isn't very nice</br>"
		filtered(text2).should == text2
    
    text3 = "<p>Weird tag <b> in the middle.</p>"
		filtered(text3).should == text3
	end
	
	it "should filter out illegal tags" do
		text1 = "This sentence <script>contains a nasty virus</script>."
    filtered(text1).should == "This sentence contains a nasty virus."
    
    text2 = "We don't like <p style='stylin'>fancy styles here.</p>"
    filtered(text2).should ==  "We don't like <p>fancy styles here.</p>"
	end
end