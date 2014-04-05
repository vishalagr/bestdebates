class UserResource < ActiveRecord::Base
  belongs_to :user
  belongs_to :resource, :polymorphic => true
  belongs_to :invite_link
  
  validates_presence_of :user_id, :resource, :resource_type

  before_save :validate_is_writable
  
  class << self
    %W(user debate).each do |m|
      define_method 'find_by_' << m do |u|      # def find_by_user(u)
        first :conditions => ["#{m}_id = ?", u]
      end
    end
  end

  protected

  # not use in validates_presence_of -> false.blank? #=> true
  def validate_is_writable
    errors.add_on_empty 'is_writable'
  end
end
