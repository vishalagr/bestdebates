class CreateBookmarks < ActiveRecord::Migration
  def self.up
    create_table :bookmarks do |t|
      t.timestamps
      t.integer :argument_id,    :null => false
      t.integer :user_id,    :null => false
    end
  end

  def self.down
    drop_table :bookmarks
  end
end
