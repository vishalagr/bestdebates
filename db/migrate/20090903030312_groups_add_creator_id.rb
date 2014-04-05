class GroupsAddCreatorId < ActiveRecord::Migration
  def self.up
    add_column :groups, :creator_id, :integer
    
    creator = User.find_by_login('PokeNProd') || User.find_by_login('admin') || User.first
    Group.all.each{|group| group.update_attribute :creator, creator}
  end

  def self.down
    remove_column :groups, :creator_id
  end
end
