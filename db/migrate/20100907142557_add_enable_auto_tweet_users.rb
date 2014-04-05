class AddEnableAutoTweetUsers < ActiveRecord::Migration
  def self.up
    add_column :users , :enable_auto_tweet, :boolean, :default => false
  end

  def self.down
    remove_column :users , :enable_auto_tweet
  end
end
