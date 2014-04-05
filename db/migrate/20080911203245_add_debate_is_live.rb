class AddDebateIsLive < ActiveRecord::Migration
  def self.up
    add_column :debates,:is_live,:integer
    for d in Debate.find(:all)
      d.update_attribute(:is_live,1)
    end
  end

  def self.down
    remove_column :debates,:is_live
  end
end
