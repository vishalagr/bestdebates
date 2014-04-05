class UsersAddUseGravatar < ActiveRecord::Migration
  def self.up
    add_column :users, :use_gravatar, :boolean
  end

  def self.down
    remove_column :users, :use_gravatar
  end
end
