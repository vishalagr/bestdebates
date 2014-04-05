class CreateDebateTwitterAccounts < ActiveRecord::Migration
  def self.up
    create_table :debate_twitter_accounts do |t|
      t.integer      :debate_id, 	:null => false
      t.integer      :twitter_account_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :debate_twitter_accounts
  end
end
