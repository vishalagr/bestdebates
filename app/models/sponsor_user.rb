class SponsorUser < ActiveRecord::Base

  validates_presence_of :sponsor, :user
  belongs_to :user
  belongs_to :sponsor, :class_name => 'User', :foreign_key => :sponsor_id
  
  def self.save_org_user(spnsr_id, usr_id)
    unless self.find_by_sponsor_id_and_user_id(spnsr_id, usr_id)
      self.create(:sponsor_id => spnsr_id, :user_id => usr_id)
    end
  end
end
