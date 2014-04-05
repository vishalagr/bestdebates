require 'digest/sha1'
class Code < ActiveRecord::Base
  belongs_to :invitation
  
  validates_presence_of   :invitation_id
  validates_uniqueness_of :unique_hash
    
  protected
  
  # Sets a +unique_hash+
  def after_initialize
    self[:unique_hash] = Digest::SHA1.hexdigest(Time.now.to_s << rand(1000).to_s) if new_record?
  end
end
