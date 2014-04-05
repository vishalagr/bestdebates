require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Video do
	
  before(:each) do
    @video = Factory.build(:video)
  end

  it "should be valid" do
    @video.should be_valid
  end

  it "should require code" do
    @video.code = nil
    @video.should have(1).error_on(:code)
  end
  
  it "should play!" do
    @video.played_times = 0
    @video.play!.should == @video.code
    @video.played_times.should == 1
  end

  it "should destroy itself after_save if !code" do
    @video.code = nil
    lambda { @video.save }.should_not change(Video, :count)

    @video.code = "Video Code XXX"
    lambda { @video.save }.should change(Video, :count).by(1)
  end

end
