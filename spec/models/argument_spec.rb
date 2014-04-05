require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Argument do

  before(:each) do
    @argument = Factory.build(:argument)
  end

  it "should check not_practice_debate" do
    @argument.debate.category = Category.practice_debate
    @argument.not_practice_debate.should be_false

    @argument.debate.category = Category.support
    @argument.not_practice_debate.should be_true
  end

  it "should be valid" do
    @argument.should be_valid
  end

  it "should require a title" do
    @argument.title = nil
    @argument.should have(1).error_on(:title)
  end

  it "should limit title to 180 characters" do
    @argument.title = 'a'*181
    @argument.should have(1).error_on(:title)
  end

  it "should require an argument_type" do
    @argument.argument_type = nil
    @argument.should have(1).error_on(:argument_type)
  end

  it "should limit argument_type to the set ['pro', 'con']" do
    @argument.argument_type = 'aye'
    @argument.should have(1).error_on(:argument_type)
  end

  it "should require a body" do
    @argument.body = nil
    @argument.should have(1).error_on(:body)
  end

  it "should be threaded" do
    @user   = Factory.create(:user)
    @debate = Factory.create(:debate)

    arg_attrs = Factory.attributes_for(:argument, :user => @user, :debate => @debate)

    @argument = Argument.create_child(arg_attrs)

    second_thread_root = Argument.create_child(arg_attrs)

    child1 = Argument.create_child(arg_attrs, @argument)
    child2 = Argument.create_child(arg_attrs, @argument)

    grandchild = Argument.create_child(arg_attrs, child1)

    @argument.reload
    child1.reload
    @argument.should be_root
    @argument.should have(2).children
    @argument.should have(3).descendants
    @debate.arguments.reject(&:parent_id).should == [@argument, second_thread_root]
    child1.parent.should == @argument
    grandchild.parent.should == child1
  end

  it "should filter the body" do
    @argument.body = "This sentence <script>contains a nasty virus</script>."
    @argument.save
    @argument.body.should == "This sentence contains a nasty virus."
  end

  it "should be taggable" do		
    @argument.tag_list.add('politics', 'parties')
    @argument.save
    Argument.find_tagged_with('politics').should == [@argument]
  end

  it "should fetch visible children" do
    @argument.save
    child1 = create_child(@argument)
    child2 = create_child(@argument)
    @argument.children_visible_to(@argument.debate.user).include?(child1)
  end
	
  it "should filter body and title" do
    @argument.body  = "this is <script>something</script> <input type='text' name='name' /> bad"
    @argument.filter_body
    @argument.body.should == "this is something  bad"

    @argument.title = "this is something good"
    @argument.filter_body
    @argument.title.should == "this is something good"
  end

  it "should check argument_type_check" do
    @argument.argument_type = "pro"
    @argument.save
    @argument.argument_type_check.should be_true
  end

  it "should update_cached_attrs!" do
    @argument.argument_type = 'pro'

    @argument.update_cached_attrs!
    @argument.relation_to_thumb.should == @argument.argument_type
    @argument.read_attribute(:bg_color).should == 0

    child = create_child(@argument, {:argument_type => 'pro'})
    @argument.update_cached_attrs!
    child.relation_to_thumb.should == child.argument_type
    child.read_attribute(:bg_color).should == 0
  end

  it "should get bg_color" do
    @argument.write_attribute(:bg_color, 1)
    @argument.bg_color.should == Argument::BG_COLOR_CODES.index(1)
  end

  it "should set bg_color!" do
    @argument.argument_type = 'pro'
    @argument.bg_color!
    @argument.read_attribute(:bg_color).should == 0
  end

  it "should set relation_to_thumb!" do
    @argument.relation_to_thumb!
    @argument.relation_to_thumb.should == @argument.argument_type

    parent_arg = Factory.create(:argument, :debate => @argument.debate, :argument_type => 'pro')
    @argument.move_to_child_of(parent_arg)

    @argument.argument_type = 'pro'
    @argument.relation_to_thumb!
    @argument.relation_to_thumb.should == 'pro'

    @argument.argument_type = 'con'
    @argument.relation_to_thumb!
    @argument.relation_to_thumb.should == 'con'
  end

  # class methods

  it "should fetch all public arguments" do
    (@argument.draft = 0)  and @argument.save
    Argument.publics.include?(@argument).should be_true

    (@argument.draft = 1)  and @argument.save
    Argument.publics.include?(@argument).should be_false
  end

  it "should get all_with_search_term" do
    argument1 = Factory.create(:argument, :title => 'something search_string something')
    argument2 = Factory.create(:argument, :body  => 'something search_string something')
    argument3 = Factory.build(:argument)
    argument3.tag_list = "search_string"
    argument3.save

    Argument.all_with_search_term('search_string').include?(argument1)
    Argument.all_with_search_term('search_string').include?(argument2)
    Argument.all_with_search_term('search_string').include?(argument3)
  end

  it "should get best_by_type_and_category" do
    @argument.debate = Factory.build(:public_debate, :category => Category.support)
    @argument.argument_type = 'pro'
    @argument.save

    Argument.best_by_type_and_category('pro', Category.support).should == @argument
  end

  it "should fetch recent arguments" do
    debate = Factory.create(:public_debate)
    @argument = Factory.build(:argument, :debate => debate, :draft => 0)
    @argument.save
    
    Argument.recent(@argument.user, {:page => 1}).include?(@argument).should be_true
  end

  # Extras

  it "should create_new_parent?" do
    @argument.dest_id = nil
    @argument.send(:create_new_parent?).should be_false

    @argument.dest_id = 1
    @argument.send(:create_new_parent?).should be_true
  end

  it "should find_new_parent" do
    @argument.save
    child_arg = Factory.build(:argument, :debate => @argument.debate)

    child_arg.dest_id = @argument.id
    child_arg.send(:find_new_parent).should == @argument

    child_arg.dest_id = nil
    child_arg.send(:find_new_parent).should == nil
  end

  it "should create_link_for" do
    @argument.save

    @argument.send(:create_link_for, 'http://www.google.com').should be_true
    @argument.send(:create_link_for, 'tp://some bad link').should be_false
  end

  it "should create_link!" do
    @argument.send(:create_link!)
  end
  
  it "should new_parent_check" do
    @argument.save
    child_arg = Factory.build(:argument, :debate => @argument.debate)

    child_arg.dest_id = 0
    child_arg.send(:new_parent_check)
    child_arg.should_not be_valid

    child_arg.dest_id = @argument.id
    child_arg.send(:new_parent_check)
    child_arg.should be_valid
  end

  it "should move! and argument" do
    @argument.save
    child_arg = Factory.create(:argument, :debate => @argument.debate)

    child_arg.dest_id = child_arg.id
    lambda { child_arg.send(:move!) }.should raise_error(ActiveRecord::ActiveRecordError)
    
    child_arg.dest_id = @argument.id
    child_arg.send(:move!)
    child_arg.parent_id.should == @argument.id
  end

  it "should assign video" do
    @argument.save
    @hash = {:code => 'SOME CODE; SOME CODE'}

    @argument.video = {}
    @argument.video.should be_nil

    @argument.video = @hash
    @argument.video.code.should == @hash[:code]

    video = Factory.create(:video, :argument => @argument)
    @argument.video = @hash
    @argument.video.code.should == @hash[:code]
  end

  it "should rate!" do
    @argument.save
    user = Factory.create(:user)
    hash = {:clarity => 3, :relevance => 8, :accuracy => 6}

    # No ratings
    lambda {
      @rating = @argument.rate!(user, hash)
    }.should change(@argument.ratings, :count).by(1)
    @rating.user.should == user


    @rating.destroy
    @rating = @argument.ratings.create!(:relevance => 2, :user => user)
    lambda {
      @rating = @argument.rate!(user,hash)
    }.should_not change(@argument.ratings, :count)
    @rating.relevance.should == 8
  end

  it "should publish an argument" do
    @argument.draft = true and @argument.save
    @argument.publish
    @argument.draft.should == 0
  end

  it "should unpublish an argument" do
    @argument.draft = false and @argument.save
    @argument.unpublish
    @argument.draft.should == 1
  end

  it "should select children_visible_to a user" do
    @argument.save
    child_arg = create_child(@argument)
    @argument.children_visible_to(@argument.debate.user).include?(child_arg).should be_true
  end

  it "should be visible_to? a user" do
    arg1 = Factory.create(:argument, :debate => Factory.create(:public_debate), :draft => false)
    arg2 = Factory.create(:argument)
    arg3 = Factory.create(:argument, :debate => Factory.create(:public_debate), :draft => true)

    arg2.visible_to?(arg1.user).should be_false

    arg1.visible_to?(arg2.user).should be_true

    arg3.visible_to?(arg3.user).should be_true

    arg2.visible_to?(arg2).should be_false # invalid user (argument)
  end

  it "should check whether an argument belonging to practice debates" do
    @argument.debate = nil
    @argument.not_practice_debate.should be_true

    @argument.debate = Factory.create(:debate, :category => Category.support)
    @argument.not_practice_debate.should be_true

    @argument.debate = Factory.create(:debate, :category => Category.practice_debate)
    @argument.not_practice_debate.should be_false
  end

  it "should check immutability" do
    arg = Factory.build(:argument)
    arg.immutable?.should be_false

    @argument.save
    @argument.immutable?.should be_false

    @argument.ratings.create
    @argument.immutable?.should be_true
  end

  it "should check ownership" do
    @argument.save
    @argument.owner?(@argument.user).should be_true
    @argument.owner?(nil).should be_false  # in[valid_user?]
  end

  it "should check can_be_modified_by? a user" do
    admin = admin_user
    @argument.save

    @argument.can_be_modified_by?(admin).should be_true

    @argument.can_be_modified_by?(@argument.user).should be_true # not immutable by default
  end

  it "should check definable" do
    @argument.definable?.should be_true # definition association is present by default

    @argument.definition = nil
    @argument.definable?.should be_false 
  end

  it "should get full_title" do
    @argument.full_title.should == "#{@argument.definition.name.to_s.upcase} - #{@argument.title}"

    @argument.definition = nil
    @argument.full_title.should == @argument.title
  end

  it "should get author_login" do
    @argument.author_login.should == @argument.user.login

    @argument.user = nil
    @argument.author_login.should be_nil
  end

  it "should set author_login" do
    lambda { @argument.author_login = nil }.should_not raise_error

    user = Factory.create(:user)
    @argument.author_login = user.login
    @argument.user.should == user
  end

  it "should save_draft" do
    arg = Factory.build(:argument, :draft => false)
    arg.save_draft
    arg.new_record?.should be_false
    arg.draft.should == 1
  end

  it "should check negates_parent?" do
    @argument.argument_type = 'pro' and @argument.save
    @argument.negates_parent?.should be_false # NO PARENT

    child = create_child(@argument)

    child.argument_type = 'pro' and child.save
    child.negates_parent?.should be_false

    child.argument_type = 'con' and child.save
    child.negates_parent?.should be_true
  end

  it "should get undefinable children" do
    @argument.save
    child1 = create_child(@argument, {:argument_type => 'pro', :definition => nil})
    child2 = create_child(@argument, {:argument_type => 'con', :definition => nil})

    res = @argument.undefinable_children("argument_type = 'pro'", "debate_id IS NOT NULL")
    res.include?(child1).should be_true
    res.include?(child2).should be_false

    @argument.instance_variable_set(:@undefinable_children, nil)

    res = @argument.undefinable_children("argument_type = 'con'")
    res.include?(child2).should be_true
  end

  it "should check whether it is rated?" do
    @argument.rated?.should be_false # new_record?
  end

  it "should derive standard_deviation" do
    @argument.send(:standard_deviation, []).should == 0
    @argument.send(:standard_deviation, [3.5]).should == 1
    @argument.send(:standard_deviation, [3.3, 2.5, 8.3]).should == Math.sqrt(@argument.send(:variance, [3.3, 2.5, 8.3]))
  end

  it "should derive variance" do
  end

  it "should calculate fact_sum" do
    lambda { @argument.send(:fact_sum, nil) }.should raise_error
    @argument.send(:fact_sum, 1).should == 55
    @argument.send(:fact_sum, 5).should == 220825
  end

  it "should get relation_to_debate" do
    @argument.argument_type = 'pro' and @argument.save
    child = create_child(@argument, {:argument_type => 'con'})
    grand_child = create_child(child, {:argument_type => 'con'})

    grand_child.relation_to_debate.should == 'pro' # -1 * -1 * 1
    child.relation_to_debate.should == 'con'       # -1 * 1
    @argument.relation_to_debate.should == 'pro'   # 1
  end

  it "should cascade_value" do
    var = Factory.build(:variable)
    @argument.cascade_value(var).should == ((@argument.score.to_f ** var.x)/(@argument.send(:fact_sum,var.x) * var.y))
  end

  it "should calculate v" do
    @argument.v.should == (@argument.vetting_percentage * 100).to_i
  end

  it "should set status from buttons" do
    argument = Factory.build(:argument)

    argument.set_status_from_buttons({'publish.x' => true})
    argument.draft.should == 0

    argument.set_status_from_buttons({:clicked_button => 'publish'})
    argument.draft.should == 0

    argument.set_status_from_buttons({'savedraft.x' => true})
    argument.draft.should == 1

    argument.set_status_from_buttons({:clicked_button => 'unpublish'})
    argument.draft.should == 1
  end

  it "should destroy_unfreeze_errors_keep" do
    @argument.save
    @argument.errors.add('debate', 'my custom error message')

    lambda { @tmp_arg = @argument.destroy_unfreeze_errors_keep }.should change(Argument, :count).by(-1)

    @tmp_arg.errors['debate'].should == 'my custom error message'
  end

  it "should recalculate_score" do
    @argument.score = 3.23 and @argument.save
    
    # ratings empty
    @argument.recalculate_score
    @argument.score.should == 0

    # average of scores of ratings
    rating1 = @argument.ratings.create(:user_id => 998, :clarity => 8)
    rating2 = @argument.ratings.create(:user_id => 999, :accuracy => 10)

    @argument.recalculate_score
    @argument.score.should == @argument.ratings.collect {|e| e.score.to_f}.sum / @argument.ratings.size

    # CHECK FOR debate.recalculate_rating
    #@argument.debate.should_receive(:recalculate_rating)
  end

  it "should get cascaded_score" do
    @argument.cascaded_score.should == @argument.ky_value(Variable.current).to_f
  end

  it "should get s" do
    # NO CODE IN MODEL
  end

  it "should get ky_value" do
    @argument.ky_value.should == @argument.score     # ratings.size < 3

    @argument.save
    child1 = create_child(@argument, {:argument_type => 'pro', :definition => nil})
    child2 = create_child(@argument, {:argument_type => 'con', :definition => nil})

    val = @argument.score
    for child in @argument.undefinable_children do
      val += ( child.score.to_f  * child.vetting_percentage  * child.cascade_value)
    end
    @argument.ky_value.should == (val / ( (@argument.undefinable_children.collect {|c| c.vetting_percentage } ).sum + 1 ))
  end

  it "should get vetting_percentage" do
    @argument.save
    @argument.vetting_percentage.should == 0         # ratings.empty?

    rating1 = @argument.ratings.create(:user => Factory.create(:user), :relevance => 8)
    rating2 = @argument.ratings.create(:user => Factory.create(:user), :relevance => 1)

    c = @argument.send(:standard_deviation, [8, 1])
    vars = Variable.current
    @argument.vetting_percentage(vars).should == (1 - (1 / (((2** vars.q)** vars.z)))) * ((4 - (c / 2)) / vars.r)
  end

  it "should get parent_with_custom_root" do
    @argument.parent_with_custom_root.should == @argument.parent_without_custom_root

    #@argument.root_argument_id = 1
    #@argument.parent_with_custom_root.should be_nil
  end

  describe "should get relations" do
    before(:each) do
      @user = Factory.create(:user)
      @debate = Factory.create(:debate, :user => @user)

      @grandparent   = Factory.create(:argument, :debate => @debate, :user => @user)
      @parent        = Factory.create(:argument, :debate => @debate, :user => @user)
      @uncle         = Factory.create(:argument, :debate => @debate, :user => @user)
      @first_cousin  = Factory.create(:argument, :debate => @debate, :user => @user)
      @second_cousin = Factory.create(:argument, :debate => @debate, :user => @user)
      @great_uncle   = Factory.create(:argument, :debate => @debate, :user => @user)
      @intermediate  = Factory.create(:argument, :debate => @debate, :user => @user)
      @second_cousin = Factory.create(:argument, :debate => @debate, :user => @user)
      @argument      = Factory.create(:argument, :debate => @debate, :user => @user)

      @parent.move_to_child_of(@grandparent.id)
      @uncle.move_to_child_of(@grandparent.id)
      @first_cousin.move_to_child_of(@uncle.id)
      @argument.move_to_child_of(@parent.id)
      @intermediate.move_to_child_of(@great_uncle.id)
      @second_cousin.move_to_child_of(@intermediate.id)
    end

    it "should get grandparent" do
      @argument.relations(1).should == [@grandparent]
    end

    it "should get uncles/aunts" do
      @argument.relations(2).should == [@uncle]
    end

    it "should get first cousins" do
      @argument.relations(3).should == [@first_cousin]
    end

    it "should get second cousins" do
      @argument.relations(4).should == [@second_cousin]
    end
  end

  def admin_user
    unless (u = User.find_by_login('admin'))
      u = Factory.create(:user, :login => 'admin')
    end
    u
  end

  def create_child(argument, extra_attrs = {})
    arg_attrs = Factory.attributes_for(:argument, :debate => argument.debate, :user => argument.user).merge(extra_attrs)
    Argument.create_child(arg_attrs, argument)
  end
end
