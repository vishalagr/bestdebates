class CreateSponsorUsers < ActiveRecord::Migration
  def self.up
    create_table :sponsor_users do |t|
      t.integer :sponsor_id
      t.integer :user_id
      t.boolean :email_sent

      t.timestamps
    end
  end

  def self.down
    drop_table :sponsor_users
  end
end
