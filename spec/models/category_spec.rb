require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Category do
	
  before(:each) do
    @category = Factory.build(:category)
  end

  it "should be valid" do
    @category.should be_valid
  end

	it "should require a name" do
    @category.name = nil
		@category.should have(1).error_on(:name)
	end
	
	it "should limit name to 50 characters" do
		@category.name = 'a'*51
		@category.should have(1).error_on(:name)
	end
	
	it "should require a description" do
    @category.description = nil
		@category.should have(1).error_on(:description)
	end
	
	it "should limit description to 80 characters" do
		@category.description = 'a'*81
		@category.should have(1).error_on(:description)
	end

  it "should get support category" do
    Category.support.name.should == 'Support'
  end

  it "should get practice debate category" do
    Category.practice_debate.name == 'Practice Debates'
  end

  it "should get practice_debate_params" do
    Category.practice_debate_params(true ).should == ["categories.name NOT LIKE ?", "Practice Debates"]
    Category.practice_debate_params(false).should == ["categories.name LIKE ?", "Practice Debates"]
  end

  it "should get category stats" do
    stats = nil
    proc {
      stats = Category.stats(1, 10, [], "debates_count DESC")
    }.should_not raise_error

    stats.size.should == ( (10 < Category.count) ? 10 : Category.count )
    stats.collect(&:debates_count).sort.reverse == stats.collect(&:debates_count)
  end

end
