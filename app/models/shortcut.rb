class Shortcut < ActiveRecord::Base

 with_options :if => :website_required? do |w|
    w.validates_format_of     :resource_url,
                                         :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix,
                                         :message => "must be a valid website"
  end
 
CATEGORIES = {"Debate" => "debates" , "Argument" => "arguments" , "General" => "general"}

  def after_save
    # autodestroy if embed code was removed and video is not new record
   if({"arguments", "debates"}.include?(self.resource_type) and self.resource_id.blank?)
    self.destroy 
   elsif self.resource_type == "general" && (self.resource_name.blank? && self.resource_url.blank?)
    self.destroy 
   end
  end

  def website_required?
    !self.resource_url.blank?
  end


end
