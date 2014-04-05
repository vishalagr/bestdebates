require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Debate do

  before(:each) do
    @debate = Factory.build(:debate)
  end

  it "should not select debates belonging to practice debates" do
    debate   = Factory.create(:debate, :category => Category.support)
    pc_debate= Factory.create(:debate, :category => Category.practice_debate)

    debate.not_practice_debate.should == true
    pc_debate.not_practice_debate.should == false
  end

  it "should be valid" do
    @debate.should be_valid
  end

  it "should require a title" do
    @debate.title = nil
    @debate.should have(1).error_on(:title)
  end

	it "should limit title to 180 characters" do
		@debate.title = 'a'*181
		@debate.should have(1).error_on(:title)
	end
	
  it "should require a body" do
    @debate.body = nil
    @debate.should have(1).error_on(:body)
  end

  it "should accept 'blank/empty' link" do
    debate_nil_link = Factory.build(:debate, :link => nil)
    debate_empty_link = Factory.build(:debate, :link => '')
    debate_nil_link.should be_valid
    debate_empty_link.should be_valid
  end

  it "should accept valid links" do
    debate1 = Factory.build(:debate, :link => 'http://www.google.com')
    debate2 = Factory.build(:debate, :link => 'https://mail.yahoo.com/')
    debate1.should be_valid
    debate2.should be_valid
  end

  it "should reject invalid links" do
    @debate.link = 'ftp://google.com.www/'
    @debate.should have(1).error_on(:link)
  end

  it "should normalize links" do
    debate = Factory.create(:debate, :link => 'www.bestdebates.com')
    debate.normalize_uri.should == 'http://www.bestdebates.com/'

    debate = Factory.create(:debate, :link => 'http://www.bestdebates.com')
    debate.normalize_uri.should == 'http://www.bestdebates.com/'

    debate = Factory.create(:debate, :link => nil)
    debate.normalize_uri.should == nil
  end

	it "should be taggable" do		
		@debate.tag_list.add('politics', 'parties')
		@debate.save
		Debate.find_tagged_with('politics').should == [@debate]
	end
	
	it "should return recent debates" do
		Debate.stub!(:find_recent).and_return([@debate])
		Debate.find_recent().should == [@debate]
	end
	
	it "should filter the body" do
		@debate.body = "This sentence <script>contains a nasty virus</script>."
		@debate.save
		@debate.body.should == "This sentence contains a nasty virus."
	end
	
  # Start of class methods

  it "should select featured debates" do
    Debate.transaction do
      debate = Factory.create(:public_debate, :category => Category.support)
      Debate.featured.include?(debate).should be_true
    end
  end

  it "should select not_draft debates" do
    debate = Factory.create(:public_debate, :draft => 0)
    Debate.not_draft.include?(debate).should be_true

    debate = Factory.create(:public_debate, :draft => 1)
    Debate.not_draft.include?(debate).should be_false
  end

  it "should select public debates" do
    debate = Factory.create(:public_debate)
    Debate.public.include?(debate).should be_true
  end

  it "should search the debates given a search term" do
    debate1 = Factory.create(:debate, :title => 'something search_string something')
    debate2 = Factory.create(:debate, :body  => 'something search_string something')
    category= Factory.create(:category, :name => 'search_string')
    debate3 = Factory.create(:debate, :category => category)
    debate3.tag_list = 'search_string' and debate3.save

    Debate.all_with_search_term('search_string').include?(debate1)
    Debate.all_with_search_term('search_string').include?(debate2)
    Debate.all_with_search_term('search_string').include?(debate3)
  end

  it "should return the debate of the day" do
    Debate.transaction do
      debate = Factory.create(:public_debate, :category => Category.support, :is_debate_of_day => true)
      Debate.of_the_day.first.should == debate
    end
  end

  it "should test whether the debate is public?" do
    debate = Factory.build(:public_debate)
    debate.public?.should be_true

    debate = Factory.build(:debate, :draft => 0, :priv => true)
    debate.public?.should be_false
  end

  it "should fetch guest invitations" do
    @debate.save
    invitation1 = Factory.create(:invitation, :resource => @debate, :resource_type => 'Debate', :invitor => @debate.user, :user => @debate.user)
    invitation2 = Factory.create(:invitation, :resource => @debate, :resource_type => 'Debate', :invitor => @debate.user, :user => nil, :last_visited => nil)

    @debate.guests.include?(invitation1).should be_false
    @debate.guests.include?(invitation2).should be_true
    @debate.guests(['last_visited IS NULL']).first.last_visited.should be_nil
  end

  it "should fetch undefinable_arguments" do
    argument = Factory.create(:argument, :definition_id => nil)
    debate   = argument.debate
    debate.undefinable_arguments.include?(argument).should be_true
  end

  it "should check whether the debate is a practice_debate?" do
    @debate.category = Category.practice_debate
    @debate.practice_debate?.should be_true
  end

  it "should print humanized_rating" do
    debate1 = Factory.build(:debate, :rating => 3.423)
    debate2 = Factory.build(:debate, :rating => nil)
    debate1.humanized_rating.should == 3.4.to_s
    debate2.humanized_rating.should == nil
  end

  it "should generate outer_url" do
    @debate.save
    @debate.outer_url.should == "http://#{HOST_DOMAIN}/debates/#{@debate.id}"
  end

  it "should check/get author_login" do
    @debate.save
    @debate.author_login.should == (@debate.user.login)
  end

  it "should set author_login" do
    debate = Factory.create(:debate)
    user   = Factory.create(:user)
    debate.author_login = user.login
    debate.user.should == user
  end

  it "should get bookmarked" do
    debate = Factory.create(:debate)
    debate.user.bookmark(debate)
    debate.bookmark_by(debate.user).should be_kind_of(Bookmark)
  end

  # app/models/debate/access.rb

  it "should be visible_to?" do
    pub_deb, priv_deb = Factory.create(:public_debate), Factory.create(:debate, :priv => true)

    pub_deb.visible_to?(pub_deb.user).should be_true
    priv_deb.visible_to?(pub_deb).should be_false    # argument: anything other than User
    priv_deb.visible_to?(priv_deb.user).should be_true
    priv_deb.visible_to?(pub_deb.user).should be_false
  end

  it "should fetch debates not belonging to `Practice Debates`" do
    @debate.category = nil
    @debate.not_practice_debate.should be_true

    @debate.category = Category.practice_debate
    @debate.not_practice_debate.should be_false

    @debate.category = Category.support
    @debate.not_practice_debate.should be_true
  end

  it "should test the ownership of the debate of a user" do
    @debate.owner?(@debate.user).should be_true
  end

  it "should check the modification rights of a user" do
    @debate.can_be_modified_by?(@debate).should be_false  # any arg other than User
    @debate.can_be_modified_by?(@debate.user).should be_true
  end

  it "should check the invitation rights of a user)" do
    @debate.can_be_invited_by?(@debate).should be_false  # any arg other than User
    @debate.can_be_invited_by?(@debate.user).should be_true
  end

  it "should check can_create_invitation?" do
    @debate.can_create_invitation?(@debate).should be_false  # any arg other than User
    @debate.can_create_invitation?(@debate.user).should be_true
  end

  it "should check can_be_read_by?" do
    @debate.can_be_read_by?(@debate.user).should be_true
    @debate.can_be_read_by?(Factory.create(:user)).should be_false
  end

  it "should check can_be_written_by?" do
    user_resource = Factory.create(:user_resource, :resource => Factory.create(:debate, :priv => true))

    user_resource.resource.can_by_written_by?(user_resource.resource.user).should be_true
    user_resource.resource.can_by_written_by?(Factory.create(:user)).should be_false
    user_resource.resource.can_by_written_by?(user_resource.user).should == user_resource.is_writable?
  end

  it "should set_debate_of_day_by_category" do
    debate1 = Factory.create(:debate, :is_debate_of_day => true)
    debate2 = Factory.create(:debate, :is_debate_of_day => false, :category => debate1.category)
    debate2.set_debate_of_day_by_category
    debate2.is_debate_of_day.should be_true
  end

  it "should filter body and title" do
    debate1 = Factory.build(:debate, :body  => "this is <script>something</script> <input type='text' name='name' /> bad")
    debate2 = Factory.build(:debate, :title => "this is something good")
    debate1.filter_body
    debate1.body.should == "this is something  bad"
    debate2.filter_body
    debate2.title.should == "this is something good"
  end

  it "should remove unacceptable tags" do
    @debate.category = Category.practice_debate
    @debate.tag_list = ['one']
    @debate.save
    @debate.rm_unacceptable_tags
    @debate.tag_list.include?('one').should be_false
  end

  it "should preset_practice_debate_tag" do
    @debate.category = Category.practice_debate and @debate.save
    @debate.tag_list.include?('Practice Debate').should be_true
  end

  it "should get stats" do
    stats = nil
    proc {
      stats = Debate.stats(1, 10, [], "arguments_count DESC")
    }.should_not raise_error

    stats.size.should == ( (10 < Debate.count) ? 10 : Debate.count )
    stats.collect(&:arguments_count).sort.reverse == stats.collect(&:arguments_count)
  end

  it "should live! and retire! a debate" do
    @debate.is_live = false

    @debate.live!
    @debate.is_live.should == 1

    @debate.retire!
    @debate.is_live.should == 0

    @debate.live
    @debate.is_live.should == 1

    @debate.retire
    @debate.is_live.should == 0
  end

  it "should recalculate rating" do
    @debate.save

    argument = Factory.create(:argument, :debate => @debate)
    rating   = Factory.create(:rating, :argument => argument)
    @debate.recalculate_rating.should be_nil

    @debate.recalculate_rating
    @debate.rating.should_not be_nil
  end

  it "should set status from buttons" do
    @debate.set_status_from_buttons({'savedraft.x' => true}, true)
    @debate.draft.should == 1

    @debate.set_status_from_buttons({:clicked_button => 'publish'})
    @debate.draft.should == 0
    @debate.priv.should == 0

    @debate.set_status_from_buttons({:clicked_button => 'unpublish'})
    @debate.draft.should == 0
    @debate.priv.should == 1

    @debate.set_status_from_buttons({})
    @debate.priv.should == 1
  end

  it "should create debate event" do
    debate = Factory.create(:debate, :user => Factory.create(:user, :fb_user_id => 238949), :fb_event_id => nil)

    # CHECK
    #debate.fb_event_id.should_not be_nil
    #debate.fb_publish_stream_id.should_not be_nil
  end

  it "should add! a joined_user" do
    invitation = Factory.create(:invitation)
    @debate.save

    record = nil
    lambda { record = @debate.joined_users.add!(invitation) }.should change(@debate.joined_users, :count).by(1)

    record.user.should == invitation.user
    record.is_writable.should == invitation.is_writable
  end

  it "should freeze and unfreeze itself" do
    @debate.freeze
    @debate.is_freezed.should be_true

    @debate.unfreeze
    @debate.is_freezed.should be_false
  end
end
