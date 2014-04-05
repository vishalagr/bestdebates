require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Group do
	
  before(:each) do
    @group = Factory.build(:group)
  end

  it "should be valid" do
    @group.should be_valid
  end

  it "should require unique name" do
    @group.name = nil
    @group.should have(1).error_on(:name)

    @group.name = 'abcdef' and @group.save
    group = Factory.build(:group, :name => @group.name)
    group.should have(1).error_on(:name)
  end

  it "should require unique_hash" do
    @group.unique_hash = nil
    @group.should have(1).error_on(:unique_hash)

    @group.unique_hash = 'abcdef' and @group.save
    group = Factory.build(:group, :unique_hash => @group.unique_hash)
    group.should have(1).error_on(:unique_hash)
  end

  it "should check owner?" do
    @group.owner?(Factory.build(:user, :is_admin => true)).should be_true
    @group.owner?(@group.creator).should be_true
  end
end
