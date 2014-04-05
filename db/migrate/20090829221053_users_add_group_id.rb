class UsersAddGroupId < ActiveRecord::Migration
  def self.up
    add_column    :users,  :group_id, :integer
    
    remove_columns :groups, :user_id, :created_at, :updated_at
  end

  def self.down
    remove_column :users, :group_id
    
    add_column :groups, :user_id,    :integer
    add_column :groups, :created_at, :datetime
    add_column :groups, :updated_at, :datetime
  end
end
