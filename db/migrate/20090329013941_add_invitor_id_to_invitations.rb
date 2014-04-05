class AddInvitorIdToInvitations < ActiveRecord::Migration
  def self.up
    add_column :invitations, :invitor_id, :integer
  end

  def self.down
    remove_column :invitations, :invitor_id
  end
end
