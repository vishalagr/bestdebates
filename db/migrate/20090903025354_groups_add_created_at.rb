class GroupsAddCreatedAt < ActiveRecord::Migration
  def self.up
    add_column :groups, :created_at, :datetime
    Group.update_all({:created_at => Time.now}, {:created_at => nil})
  end

  def self.down
    remove_column :groups, :created_at
  end
end
