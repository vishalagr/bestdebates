class FacebookPermission < ActiveRecord::Base
  set_primary_key :user_id
  
  belongs_to :user
  validates_presence_of :user
# validates_associated  :user
end
