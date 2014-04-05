class AddReceivePrivateMessage < ActiveRecord::Migration
  def self.up
	  add_column :users, :receive_priv_msgs, :boolean, :default => true
  end

  def self.down
	remove_column :users, :receive_priv_msgs
  end
end
