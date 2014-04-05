class AddSomeAttributesToInvitations < ActiveRecord::Migration
  def self.up
    add_column :invitations, :guest_id, :integer
    add_column :invitations, :user_id, :integer
    add_column :invitations, :is_writable, :boolean
  end

  def self.down
    remove_column :invitations, :guest_id
    remove_column :invitations, :user_id
    remove_column :invitations, :is_writable
  end
end
