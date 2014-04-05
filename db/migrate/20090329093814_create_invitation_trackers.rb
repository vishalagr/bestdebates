class CreateInvitationTrackers < ActiveRecord::Migration
  def self.up
    create_table :invitation_trackers do |t|

      t.integer :invitation_id
      t.integer :message_id
      t.boolean :is_writable
      t.timestamps
    end
  end

  def self.down
    drop_table :invitation_trackers
  end
end
