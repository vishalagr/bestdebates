require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe Rating do
	
	describe "validations on ratings" do
		
	  def validate_range_for(col, low = 0, high = 10)
	    @rating.should have(1).error_on(col)
	    @rating.send("#{col.to_s}=", low - 1)
	    @rating.should have(1).error_on(col)
	    @rating.send("#{col.to_s}=", high + 1)
	    @rating.should have(1).error_on(col)
	  end
  
	  before(:each) do
	    @rating = Factory.build(:rating)
	  end

	  it "should be valid" do
	    @rating.should be_valid
	  end
  
    it "should require user" do
      @rating.user = nil
      @rating.should have(1).error_on(:user_id)
    end

    it "should require argument" do
      @rating.argument = nil
      @rating.should have(1).error_on(:argument_id)
    end

	  it "should require valid clarity" do
      @rating.clarity = nil
	    validate_range_for :clarity, 0, 10
	  end
  
	  it "should require valid relevance" do
      @rating.relevance = nil
	    validate_range_for :relevance, 0, 10
	  end
  
	  it "should require valid accuracy" do
      @rating.accuracy = nil
	    validate_range_for :accuracy, -10, 10
	  end

    it "should calculate score" do
      @rating.accuracy, @rating.clarity, @rating.relevance = 0, 0, 0
      @rating.score.should == ''

      @rating.accuracy, @rating.clarity, @rating.relevance = 5, 6, 7
      @rating.score.length.size == 4
    end
	
	end
	
end
