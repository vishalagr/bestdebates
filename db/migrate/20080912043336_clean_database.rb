class CleanDatabase < ActiveRecord::Migration
  def self.up
    for d in Debate.find(:all)
    #unpublish all of the content except the global warming debate
        d.update_attribute(:is_live,(d.id==3))
   end
  end

  def self.down
  end
end
