class TwitterAccount < ActiveRecord::Base
  validates_presence_of :twitter_username,:twitter_password
  validates_uniqueness_of :twitter_username,    :case_sensitive => false
  has_many :debate_twitter_accounts, :dependent => :delete_all
  has_many :twitter_debate_categories , :dependent => :nullify
end
