class Group < ActiveRecord::Base  
  belongs_to :creator, :class_name => 'User'
  
  has_many :invitations
  has_many :members, :class_name => 'User', :dependent => :nullify

  validates_presence_of   :name, :unique_hash
  validates_uniqueness_of :name, :unique_hash

  # Checks whether +user+ is the owner of the group
  def owner?(user)
    user.admin? or creator == user
  end  

  def after_initialize
    self[:unique_hash] = Digest::SHA1.hexdigest(Time.now.to_s << rand(1000).to_s) if new_record?
  end
end
