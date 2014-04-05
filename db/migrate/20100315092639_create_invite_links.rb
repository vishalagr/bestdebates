class CreateInviteLinks < ActiveRecord::Migration
  def self.up
    create_table :invite_links do |t|
      t.string :title
      t.string :unique_id
      t.integer :debate_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :invite_links
  end
end
