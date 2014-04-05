class Argument < ActiveRecord::Base
  # Argument model

  RATING_COEFFICIENT = 50.0
  
  # RSS unlimited depth
  RSS_UNLIMITED_DEEP  = 0

  # RSS default depth
  RSS_DEFAULT_DEEP    = RSS_UNLIMITED_DEEP

  # RSS available depths
  RSS_AVAIVABLE_DEEPS = [RSS_UNLIMITED_DEEP, 1,2, 3, 5, 10, 25]

  # Rss available depths for argument creation
  RSS_AVAIVABLE_DEPTHS = [1,2, 3, 5, 10]
  # List of available tabs
  TABS = {:watching => 0, :rating => 1, :reply => 2, :tags => 3, :links => 4, :edit => 5, :video => 6, :bookmark => 7, :duparg => 8, :contexts => 9,:drafts => 10,:image=>11}

  # Relations
  # To display on 'argument show' page
  RELATIONS = {
    'Grandparent'    => 1,
    'Uncles/Aunts'   => 2,
    'First Cousins'  => 3,
    'Second Cousins' => 4,
    'Siblings'       => 5
  }

  # Thinking Sphinx indexing
  define_index do
    indexes [:title, :body]
    where "debate_id!=0"

  set_property :enable_star => true
  set_property :min_prefix_len => 3
  end
    
  concerned_with :cached_attrs, :class_methods, :validates, :callbacks, :extras

  file_column :image ,:magick => { :geometry => "120x140" ,
    :versions => { "thumb" => "50x50", "large" => "640x480>" }},
                      :root_path => File.join(RAILS_ROOT, "public/system"),
                      :web_root => 'system/'

  default_values :draft => true, :ratings_count => 0, :score => 0
  
#  is_indexed :fields => [:title, :body], :conditions => 'draft=0', :delta => true
  
  acts_as_nested_set :scope => :root, :dependent => :destroy
	acts_as_taggable
  
	belongs_to :debate
	belongs_to :user, :counter_cache => true
	belongs_to :root
  belongs_to :definition
  belongs_to :parent,
    :class_name => 'Argument',
    :foreign_key => 'parent_id'
  has_many :arguments
  
  with_options :dependent => :destroy do |d|
    d.has_many :ratings
    d.has_many :argument_links
    d.has_many :bookmarks
    d.has_one  :video
    d.has_many :invitations, :as => :resource
    d.has_many :invite_links, :as => :resource
    d.has_many :subscriptions
  end
  
  has_many :joined_users, :class_name => 'UserResource', :as => :resource, :dependent => :delete_all do
    def add!(invitation)
      create! :user => invitation.user, :is_writable => invitation.is_writable
    end
  end
  
  # invited, but not respond yet to an invitation
  has_many :invited_users, 
           :select  => 'users.*, invitations.id as invitation_id, invitations.is_writable',
           :through => :invitations,
           :source => :user,
           :conditions  => 'user_id IS NOT NULL'

  has_one :similar_argument, :dependent => :destroy
	alias links argument_links
  
  # dest_id is used to store the id of parent argument
	attr_accessor :dest_id, :link_url, :html_id
  # setup a custom root_argument
  attr_accessor :root_argument_id
  
  alias author user
  
  # generates parent with custom root
  def parent_with_custom_root(force=false)
    return parent_without_custom_root if !root_argument_id || force
    
    r = parent_without_custom_root
    if r.id == root_argument_id 
      nil
    else
      r.root_argument_id = root_argument_id   
      r     
    end
  end
  alias_method_chain :parent, :custom_root
  
  # old rails hack
  def video=(hash)
    if video
      video.update_attribute :code, hash[:code]
    else
      return if hash[:code].blank?
      create_video :code => hash[:code]
      self.errors.add(video.errors)
    end
  end
  def most_accessed!
    increment! :most_accessed
  end
  # checks whether children to the argument are visible to a given user
  def children_visible_to(user)
    children.select {|a|a.visible_to?(user)  }  
  end
  
  # Rate the argument
	def rate!(user, attributes)
    # should raise an exception
		rating = ratings.find_by_user_id(user.id)
		if rating
			rating.update_attributes!(attributes) # ActiveRecord::RecordNotSaved
		else
			rating = ratings.create!(attributes.merge(:user => user)) # ActiveRecord::RecordInvalid
		end 
    recalculate_score # for re calculating argument rating and overall debate score.
    save!
		rating
	end
	
  # Publish the argument i.e., set the draft attribute to false
	def publish
	  update_attributes! :draft => false
	end
	
  # Unpublish the argument i.e., set the draft attribute to true
	def unpublish
	  update_attributes! :draft => true
	end

  # Returns an unsaved/new-record clone of the +self+ retaining the errors object
  def destroy_unfreeze_errors_keep
    return self if self.new_record?

    errors = self.errors
    self.destroy

    tmp_argument    = self.clone # unfreeze hash
    tmp_argument.id = nil # mark object as new_record
    unless errors.blank? and errors.respond_to?(:each)
      errors.each do |attribute, msg|
        tmp_argument.errors.add(attribute, msg)
      end
    end
    
    tmp_argument
  end
  
  # Sets the argument status of +self+
  # publishes or saves as draft +self+ depending on certain keys in +params+ hash
  def set_status_from_buttons(params)
    # self.unpublish  if params['unpublish.x'] || params[:clicked_button] == 'unpublish'
    if    params['publish.x']   or (params[:clicked_button] == 'publish')
      self.publish
    elsif params['savedraft.x'] or (params[:clicked_button] == 'unpublish')
      self.save_draft
    end
    
  end

  # Recalculates score of the argument
  def recalculate_score
    update_attribute(:score, 0) and return if ratings.empty?
    
    update_attribute(:score, (ratings.collect{|e| e.score.to_f}).sum / ratings.size )
    debate.recalculate_rating
  end
  
  # can user read an argument
  def visible_to?(u)
    return false unless self.debate.visible_to?(u) # false if debate is unaccessible

    return true if !draft? # all public args
    return true if  draft? && owner?(u) # show draft argument if current user is owner
    
    false
  end
  def searchable_to?(u)    
    #bookmark = Bookmark.find(:all, :conditions => ["argument_id = ? " , self.id])
    #if !bookmark.blank?
     #return bookmark.collect(&:user_id).include?(u.id)
    #end
   return false unless self.debate.searchable_to?(u) # false if debate is unaccessible

   return true if !draft? # all public args
   return true if  draft? && owner?(u) # show draft argument if current user is owner

   false
  end
  # not belonging to `Practice Debates` debate
  def not_practice_debate
    return true unless self.debate
    self.debate.not_practice_debate
  end

#  def can_subscribe?(sub)
#    parent_arg = Subscription.find(:first, :conditions => ["argument_id = ? and status = 1", self.parent_id])
#    if parent_arg.blank?
#      true
#    else
#      (sub.deep > parent_arg.deep || sub.deep == 0 ) && sub.email == parent_arg.email
#    end
#  end
  def level_with_respective_parent(parent_argument)
    return self.level - parent_argument.level
  end
  # title of the argument
  # hides the title and returns "(not live)" if the argument isn't live
  # returns '*No title*' if title attribute is blank
#  def title
#    ttl = read_attribute :title
#    if !self.new_record?
#      if debate
#        puts "iam here"
#        puts debate.is_live
#        if !debate.is_live?
#          return("(<b>not public</b>) #{ttl}")
#        end
#      end
#      return '*No title*' if ttl.blank?
#
#    end
#    ttl
#  end
      
  # can the argument be modified by the given user
  def can_be_modified_by?(u)
    return true if (valid_user?(u) and u.admin?)
    !immutable? and owner?(u)
  end
  
  # Checks whether the argument can be invited by the given user +u+
  def can_be_invited_by?(u)
    return false unless valid_user?(u)
    self.user_id == u.id or u.admin? or !self.draft?
  end

  # is the given user owner of the argument
  def owner?(u)
    return true if valid_user?(u) and self.user_id == u.id
    false
  end
  
  # checks whether the argument is immutable
  # an argument is immutable if it has got no ratings and children (child arguments)
  def immutable?
    return false if new_record?
    # false until someone has posted a response, or rated me
    return true if self.ratings.size > 0 || self.children.size > 0
    false
  end
  
  # checks whether the argument is bookmarked by the given user
  def bookmark_by(user)
    Bookmark.bookmark_by(user, self)
  end
  
  # s
  def s(vars= Variable.current)
    #cascaded_score.halt
  end
    
  # returns +cascaded_score+ of the argument for a given set of variables
  def cascaded_score(vars= RatingVariable.current)
    ky_value(vars).to_f
  end
  
  # returns the vetting number of the argument
  def v
    (vetting_percentage * 100).to_i
  end

  # returns the vetting_percentage of the argument for a given set of variables
  def vetting_percentage(vars= Variable.current)
    return 0 if ratings.empty?
    c = standard_deviation(ratings.collect{|rating| rating.relevance})
    (1 - (1 / (((ratings.size** vars.q)** vars.z)))) * ((4 - (c / 2)) / vars.r)
  end 
  
  # returns the cascade_value of the argument for a given set of variables
  def cascade_value(vars= RatingVariable.current)
    fact_sum = fact_sum(vars.x) 
    ((score.to_f** vars.x) / (fact_sum * vars.y))
  end 
  
  # returns +ky_value+ of the argument for a given set of variables
  def ky_value(vars= RatingVariable.current)
    return score if ratings.size < 3 or !(undefinable_children('ratings_count > 2'))
    val = score
    for child in undefinable_children do
      val += ( child.score.to_f  * child.vetting_percentage(Variable.current)  * child.cascade_value(vars))
    end
    val / ( (undefinable_children.collect {|c| c.vetting_percentage } ).sum + 1 )
  end

  # plain extras
  def undefinable_children(*extra_conds)
    @undefinable_children ||= children.all :conditions => (extra_conds << 'definition_id is NULL ').join(' AND ')
  end

  # Return full title of the argument
  # if the argument is definable, +upcase+d definition name is prepended to the title attribute
  # otherwise the title attribute is returned as it is
  def full_title
    (definable? ? definition.name.to_s.upcase + " - " : "") + (debate && !debate.is_live? ? "(<b>not public</b>) #{title}" : title)
  end

  # Check whether the argument is definable?
  def definable?
    self.definition_id?
  end

  # Check whether the argument is rated
  # an argument is rated when it isn't a new_record and its vetting_percentage and score are non-zero
  def rated?
    !new_record? and vetting_percentage.to_f != 0.0 and score != 0.0
  end

  # TODO: cache it!
  # relation of the argument to the debate
  def relation_to_debate
    relation = 1
    p = self
    while p != nil
      relation = relation * (p.argument_type == "pro" ? 1 : -1)
      p = p.parent
    end
    relation == 1 ? "pro" : "con"
  end

  def outer_url
    "http://#{HOST_DOMAIN}/arguments/#{self.id}"
  end



  # Return login name of the creator/author of the argument
  def author_login
    user.login if user
  end
    
  # Set the user with given login name as the creator/author of the argument
  def author_login=(login)
    return if login.blank?
    self.user = User.find_by_login(login)
  end
  
  # Save the argument as a draft
  def save_draft
    save
    unpublish
  end  
  
  # Checks whether the argument negates its parent
  # Returns false if the argument doesn't have a parent
  def negates_parent?
    return parent.argument_type != self.argument_type if parent    
    false
  end

  # Returns invitations (guests) corresponding to the debate +self+
  def guests(extra_conditions=nil)
    conditions = 'user_id is NULL'
    
    if extra_conditions.is_a?(Array)
      conditions = extra_conditions.first << ' AND ' << conditions 
      #conditions = extra_conditions
    end
    
    invitations.all(:conditions => conditions)
  end
  
  # Returns the list of all arguments related to self by relation `relation_type`
  # See RELATIONS constant for available relations
  def relations(relation_type)
    case relation_type.to_i
    when RELATIONS['Grandparent']
      (self.parent and self.parent.parent) ? [self.parent.parent] : []
    when RELATIONS['Uncles/Aunts']
      self.parent ? self.parent.siblings.select {|arg| arg.debate_id == self.debate_id} : []
    when RELATIONS['First Cousins']
      uncles = (self.parent ? self.parent.siblings.select {|arg| arg.debate_id == self.debate_id} : [])
      arr = []
      uncles.each do |uncle|
        arr << uncle.children
      end
      return arr.flatten
    when RELATIONS['Second Cousins']
      grand_parent = ((self.parent and self.parent.parent) ? self.parent.parent : nil)
      great_uncles = (grand_parent ? grand_parent.siblings.select {|arg| arg.debate_id == self.debate_id} : [])
      arr = []
      great_uncles.each do |great_uncle|
        great_uncle.children.collect do |x|
          arr << x.children
        end
      end
      return arr.flatten
    when RELATIONS['Siblings']
      self.siblings.select {|a| a.debate_id == self.debate_id}
    end
  end

#  protected
#
#  disabled temporally as was asked
#  def validate
#    errors.add(:definition_id, ", can't be blank.") if definable? && !Definition.find_by_id(definition_id)
#  end
  
  private
    
  # Returns fact
  def fact_sum(int)
    sum = 0
    i=0
    while (i+=1) <= 10
      sum+=  i** int
    end
    sum
  end
  
  # Returns variance of the given population
  def variance(population)
    n = 0
    mean = 0.0
    s = 0.0
    population.each { |x|
      n = n + 1
      delta = x - mean
      mean = mean + (delta / n)
      s = s + delta * (x - mean)
    }
     s / n
  end

  # Returns standard_deviation of the given population
  def standard_deviation(population)
    return 0 if population.empty?
    return 1 if population.size == 1
    Math.sqrt(variance(population))
  end
end
