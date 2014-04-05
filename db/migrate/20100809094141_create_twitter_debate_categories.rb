class CreateTwitterDebateCategories < ActiveRecord::Migration
  def self.up
    create_table :twitter_debate_categories do |t|
      t.integer      :category_id, 	:null => false
      t.integer      :twitter_account_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :twitter_debate_categories
  end
end
