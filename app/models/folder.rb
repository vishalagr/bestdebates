class Folder < ActiveRecord::Base
  belongs_to :user
  has_many :private_messages, :class_name => "PrivateMessageCopy"
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :user_id
  
  attr_accessible :name
end
