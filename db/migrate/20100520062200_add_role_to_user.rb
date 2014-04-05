class AddRoleToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :role, :string, :default => 'normal'
    
    # Migrate all the existing admin users
    User.find(:all, :conditions => {:is_admin => true}).each do |user|
      user.update_attribute(:role, 'admin')
    end

    remove_column :users, :is_admin
  end

  def self.down
    add_column :users, :is_admin, :boolean, :default => false
    remove_column :users, :role
  end
end
