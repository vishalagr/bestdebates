class Argument < ActiveRecord::Base
  include TweetGenerator

  before_validation :new_parent_check
  before_save       :argument_type_check, :filter_body

  # twitter
  after_create      :generate_tweet
  #after_create      :global_watching_email if %W/production/.include?(RAILS_ENV)
  #facebook Feed Publish
  after_create  :publish_argument_to_facebook
  # Checks for a change in +argument_type+ attribute of the argument
  # Sets an instance variable
  def argument_type_check
    @argument_type_changed = argument_type_changed?
    true # return true to avoid ActiveRecord::RecordNotSaved
  end  
  # execute only if instance is unsaved or after_save block is already executing
  # the below method will also raise after_save callback, so need to skip it
  def after_save
    return if @skip_after_save
    @skip_after_save = true
        
    move!
    create_link!    
    update_cached_attrs! #if @argument_type_changed # update cached_attrs only after argument type change
    
    @skip_after_save = false # see the comment at the top
    true # return true to avoid ActiveRecord::RecordNotSaved
  end

  def global_watching_email
    Mailers::Debate.deliver_global_admin_watching_email(self)
  end
  # Filter the body and title for HTML or javscript injection
  def filter_body
		self.body  = Sanitize.clean(self.body,  Sanitize::Config::BASIC) unless self.body.blank?
		self.title = Sanitize.clean(self.title, Sanitize::Config::BASIC) unless self.title.blank?
    true
	end

  # Tweet Generator
  def generate_tweet
    begin
      if self.debate
        if !("Practice Debates" "Suggestions" "Support" "Tutorials").include?(self.debate.category.name)
          url = "http://#{HOST_DOMAIN}/arguments/#{self.id}"
          push_tweet(self.title, url)
        end
=begin
        if self.debate.category.twitter_debate_category
          if self.debate.category.twitter_debate_category.twitter_account
             argument_to_debate_twitter(self.debate.category.twitter_debate_category.twitter_account.twitter_username,self.debate.category.twitter_debate_category.twitter_account.twitter_password)
          end
          if self.debate.category.twitter_debate_category.twittertwo
            argument_to_debate_twitter(self.debate.category.twitter_debate_category.twittertwo.twitter_username,self.debate.category.twitter_debate_category.twittertwo.twitter_password)
          end
        end
        
        if self.debate.debate_twitter_account
          argument_to_debate_twitter(self.debate.debate_twitter_account.twitter_account.twitter_username,self.debate.debate_twitter_account.twitter_account.twitter_password)
        end
        
        if self.user.enable_auto_tweet
           @user_tweet = UserTwitterAccount.find_by_user_id(self.user.id)
           if !@user_tweet.blank?
             argument_to_debate_twitter(@user_tweet.twitter_username,@user_tweet.twitter_password)
           end
        end
=end
      end

    rescue
    end
  end
  #tweets to debate twitter account
  def argument_to_debate_twitter(username,password)
    require 'twitter' # twitter4r-0.3.2 require
    # Configuration parameters         
      twitter_username = username
      twitter_password = password
      url = "http://#{HOST_DOMAIN}/arguments/#{self.id}"
      tweet = "#{self.title[0, 100]} #{short_url(url)}"
      begin
        # Let's get a Twitter Client created
        client = Twitter::Client.new(:login => twitter_username, :password => twitter_password)
        client.status(:post,tweet)
      rescue Twitter::RESTError
      end      
   end

  def publish_argument_to_facebook
    if self.user.fb_user?     
      publish_stream_id = Facebook::Tasks.publish_argument_to_user_wall(self)
      update_attribute(:fb_publish_stream_id, publish_stream_id) if publish_stream_id      
    end
  end

end
