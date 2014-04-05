class Video < ActiveRecord::Base
  # use http://github.com/mdarby/acts_as_video_fu/tree
  
  default_value_for :played_times, 0
  
  belongs_to :argument
  
  validates_presence_of :code, :if => proc{|v| v.new_record?}
  
  # Plays a video
  # 
  def play!
    increment! :played_times
    code
  end
  
  # After save callback
  def after_save
    # autodestroy if embed code was removed and video is not new record
    self.destroy if self.code.blank?
  end
end
