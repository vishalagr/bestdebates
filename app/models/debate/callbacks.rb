class Debate < ActiveRecord::Base
  include TweetGenerator

  before_validation_on_create :set_debate_of_day_by_category
  before_save                 :filter_body
  after_create                :create_debate_event

  # tags
  after_create                :preset_practice_debate_tag
  after_save                  :rm_unacceptable_tags

  # twitter
  after_create                :generate_tweet, :if => :public?
  after_create                :global_watching_email if %W/production/.include?(RAILS_ENV)
  # Sets the debate of the day by category
  def set_debate_of_day_by_category
    # save current debate as 'debate of day'(DoD) if it have the same category as any other DoD
    self.class.all(:select => "distinct(category_id)", :conditions => {:is_debate_of_day => true}).each do |d|
      self.is_debate_of_day = true and break if d.category_id == self.category_id
    end
	end
  
  # Filter the body and title of the debate for HTML and Javascript code
  def filter_body
		self.body  = Sanitize.clean(self.body,  Sanitize::Config::BASIC) unless self.body.blank?
		self.title = Sanitize.clean(self.title, Sanitize::Config::BASIC) unless self.title.blank?
	end

  # Creates debate event in facebook
  def create_debate_event
    if self.user.fb_user?
      event_id = Facebook::Tasks.create_debate_event(self)
      update_attribute(:fb_event_id, event_id) if event_id

      publish_stream_id = Facebook::Tasks.publish_debate_to_user_wall(self)
      update_attribute(:fb_publish_stream_id, publish_stream_id) if publish_stream_id
    end
  end

  # For every creation of debate an email sent to watching@bestdebates.com
  def global_watching_email
    Mailers::Debate.deliver_global_admin_watching_email(self)
  end

  # remove all exists taggable connections for a debate from Practice Debate category
  def rm_unacceptable_tags
    if !@skip_rm_unacceptable_tags and practice_debate?
      tag_list.each{|current_tag| tag_list.remove(current_tag) unless current_tag == PRACTICE_DEBATE_TAG}
      @skip_rm_unacceptable_tags = true
      save!
    end
#    self.taggings.each(&:destroy) if practice_debate?
  end

  # Presets practice debate tag
  def preset_practice_debate_tag
    tag_list.add(Debate::PRACTICE_DEBATE_TAG) && save! if practice_debate?
  end

  # Tweet Generator
  def generate_tweet
    if !("Practice Debates" "Suggestions" "Support" "Tutorials").include?(self.category.name)
      url = "http://#{HOST_DOMAIN}/debates/#{self.id}"
      push_tweet(self.title, url)
    end
=begin
    if self.category.twitter_debate_category
      if self.category.twitter_debate_category.twitter_account
        debate_by_category_to_twitter(self.category.twitter_debate_category.twitter_account.twitter_username,self.category.twitter_debate_category.twitter_account.twitter_password)
      end
      if self.category.twitter_debate_category.twittertwo
        debate_by_category_to_twitter(self.category.twitter_debate_category.twittertwo.twitter_username,self.category.twitter_debate_category.twittertwo.twitter_password)
      end
    end
=end
  end

   def debate_by_category_to_twitter(username,password)
    require 'twitter' # twitter4r-0.3.2 require
    # Configuration parameters    
      twitter_username = username
      twitter_password = password
      url = "http://#{HOST_DOMAIN}/debates/#{self.id}"
      tweet = "#{self.title[0, 100]} #{short_url(url)}"
      begin
        # Let's get a Twitter Client created
        client = Twitter::Client.new(:login => twitter_username, :password => twitter_password)
        client.status(:post,tweet)
      rescue Twitter::RESTError
      end    
   end
   
   def twitter_authorize
      Twitter::Client.configure do |conf|# App configuration
      conf.application_name = 'test4rapp)))'
      conf.application_version = '1.0'
      conf.application_url = "http://#{HOST_DOMAIN}/"
      #  App OAuth token key/secret pair      
      conf.oauth_consumer_token = "kMxiDRjX0PWaiuSnpGDrVg"      
      conf.oauth_consumer_secret = "IjFrcARdO4LfxSvLs0Z8zpefoDqrfWY8vuTwGFrtg"
      
    end
   end
   
end
