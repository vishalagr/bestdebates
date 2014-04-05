class TwitterDebateCategory < ActiveRecord::Base
  belongs_to :category
  belongs_to :twitter_account
  belongs_to :twittertwo, :class_name => 'TwitterAccount' , :foreign_key => 'twitter_account_id_two'


  class << self
    def create_or_update(attributes,id)
      debate_category_twitter = find(:first , :conditions => ["category_id = ?", id])
      if !debate_category_twitter.blank?
        if !attributes[:twitter_account_id].blank?          
         return "Twitter Accounts having Duplicates."  if debate_category_twitter.twitter_account_id_two == attributes[:twitter_account_id].to_i
        end
        if !attributes[:twitter_account_id_two].blank?         
         return "Twitter Accounts having Duplicates." if debate_category_twitter.twitter_account_id == attributes[:twitter_account_id_two].to_i
        end       
        debate_category_twitter.update_attributes(attributes)
        return "Twitter Account was updated successfully to the Debate Category."
      else
        debate_category_twitter = TwitterDebateCategory.new(attributes)
        debate_category_twitter.save
        return "Twitter Account was added successfully to the Debate Category."
      end      
    end
  end
end
