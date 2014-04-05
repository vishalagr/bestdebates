class ActivateAllDebates < ActiveRecord::Migration
  def self.up
    for d in Debate.find(:all)
      d.update_attribute(:is_live,1)
    end
  end

  def self.down
  end
end
