class CreateTwitterAccounts < ActiveRecord::Migration
  def self.up
    create_table :twitter_accounts do |t|
      t.string      :twitter_username, 	:null => false
      t.string      :twitter_password, 		:null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :twitter_accounts
  end
end
