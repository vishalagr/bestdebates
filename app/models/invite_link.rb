class InviteLink < ActiveRecord::Base

  belongs_to :resource, :polymorphic => true
  belongs_to :user

  has_many :user_resources

  validates_presence_of :unique_id, :resource, :resource_type, :user
  validates_uniqueness_of :unique_id, :if => Proc.new { |l| !l.unique_id.blank? }

  # Additional validation for +invite_link+ to check uniqueness of +title+ attribute
  def validate
    if !self.title.blank? and self.user_id? and InviteLink.exists?(:title => self.title, :user_id => self.user.id)
      self.errors.add('title', 'You have already created an invitation title with that name')
    end
  end

  # Returns the list of all invited users invited through the invite_link
  def invited_users
    self.user_resources.collect(&:user)
  end

  # Adds the given user +u+ to the list of joined_users of the invite_link's resource
  def connect!(u)
    unless resource.joined_users.exists?(:user_id => u.id, :invite_link_id => self.id)
      resource.joined_users.create!(:user_id => u.id, :invite_link_id => self.id)
    end
  end
  
  # Returns the +title+ attribute of the invite_link if present
  # else, the +unique_id+ is returned
  def display_title
    (self.title.blank? ? self.unique_id : self.title)
  end
end
