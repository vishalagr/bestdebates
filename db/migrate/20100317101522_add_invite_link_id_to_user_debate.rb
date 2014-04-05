class AddInviteLinkIdToUserDebate < ActiveRecord::Migration
  def self.up
    add_column :user_debates, :invite_link_id, :integer
  end

  def self.down
    remove_column :user_debates, :invite_link_id
  end
end
