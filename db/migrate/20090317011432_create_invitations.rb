class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.integer :debate_id
      t.integer :group_id
      t.integer :member_id

      t.datetime :first_visited
      t.datetime :last_visited
    end
  end

  def self.down
    drop_table :invitations
  end
end
