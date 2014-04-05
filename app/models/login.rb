class Login < ActiveRecord::Base
  COOKIES_IDENTIFIER = :vistor_id
  # COOKIES_IDENTIFIER == loginid
  
  belongs_to :user
  
  default_values    :visits => 0, :duration => 0
  default_value_for :loginid do # to aviod a value caching
    Time.now.to_f    
  end
  
  validates_presence_of     :name, :if => proc{|u| u.user_id.blank?}
  validates_presence_of     :loginid, :duration
  validates_numericality_of :visits,  :only_integer => true
  
  alias_attribute COOKIES_IDENTIFIER, :loginid
  
  class << self
    # Creates a login from the given +session_id+
    def create_from_session_id!(session_id, args={})
      create! args.merge!(:sessid => session_id)
    end
  end
  
  # Update the +duration+ attribute with the duration of the visit or 15 minutes whichever is minimum
  # Increment the +visits+ attribute
  def visit!
    self.duration = [(Time.now - self.updated_at).to_i, 15 * 30].min # if user stay on page more than 15 min
    self.visits += 1
    self.save!
  end
end
