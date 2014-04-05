class CreateUserTwitterAccounts < ActiveRecord::Migration
  def self.up
    create_table :user_twitter_accounts do |t|
      t.string   :twitter_username, 	:null => false
      t.string   :twitter_password, 	:null => false
      t.integer  :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :user_twitter_accounts
  end
end
