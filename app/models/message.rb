class Message < ActiveRecord::Base
  has_many :invitations

  validates_presence_of :body
end
