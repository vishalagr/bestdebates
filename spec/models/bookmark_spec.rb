require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Bookmark do
	
  before(:each) do
    @bookmark = Factory.build(:bookmark)
  end

  it "should be valid" do
    @bookmark.should be_valid
  end

  it "should require a user" do
    @bookmark.user_id = nil
    @bookmark.should have(1).error_on(:user_id)
  end

  it "should create_obj" do
    argument = Factory.create(:argument)
    Bookmark.create_obj(argument, argument.user).should be_true
    Bookmark.create_obj(argument.debate, argument.user).should be_true
  end

  it "should bookmark_by" do
    argument = Factory.create(:argument)

    Bookmark.create_obj(argument, argument.user)
    b = Bookmark.bookmark_by(argument.user, argument)
    b.user.should == argument.user
    b.argument.should == argument

    Bookmark.create_obj(argument.debate, argument.user)
    b = Bookmark.bookmark_by(argument.user, argument.debate)
    b.user.should == argument.user
    b.debate.should == argument.debate
  end

  it "should get obj" do
    @bookmark.argument = nil
    @bookmark.save
    @bookmark.obj.should == @bookmark.debate

    @bookmark.debate = nil
    @bookmark.save
    @bookmark.obj.should == nil
  end

  it "should get title" do
    @bookmark.save
    @bookmark.title.should == @bookmark.obj.title
  end

  it "should get url" do
    @bookmark.save
    @bookmark.url.should =~ /\/arguments\/#{@bookmark.argument.id}\/?$/

    @bookmark.argument = nil and @bookmark.save
    @bookmark.url.should =~ /\/debates\/#{@bookmark.debate.id}\/?$/
  end

end
