require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Definition do
	
  before(:each) do
    @definition = Factory.build(:definition)
  end

  it "should be valid" do
  end

  it "should require unique name" do
    @definition.name = nil
    @definition.should have(1).error_on(:name)

    @definition.name = 'abcdef' and @definition.save
    definition = Factory.build(:definition, :name => @definition.name)
    definition.should have(1).error_on(:name)
  end
end
