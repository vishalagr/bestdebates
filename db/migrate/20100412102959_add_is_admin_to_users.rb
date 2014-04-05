class AddIsAdminToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :is_admin, :boolean, :default => false

    # Retaining existing admin
    User.update_all('is_admin = 1', "login = 'admin'")
  end

  def self.down
    remove_column :users, :is_admin
  end
end
