class UserTwitterAccount < ActiveRecord::Base

  validates_presence_of   :twitter_username , :twitter_password
  
  belongs_to :users
  
end
