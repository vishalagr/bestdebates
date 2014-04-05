class AddSecTwitterCategories < ActiveRecord::Migration
  def self.up
    add_column :twitter_debate_categories ,:twitter_account_id_two , :integer , :null => false , :default => 0
    execute("ALTER TABLE twitter_debate_categories CHANGE twitter_account_id twitter_account_id INT( 11 ) NOT NULL DEFAULT '0' ")
  end

  def self.down
    remove_column :twitter_debate_categories ,:twitter_account_id_two
  end
end
