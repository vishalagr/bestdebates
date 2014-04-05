class AddBookmarkTextColBookmarks < ActiveRecord::Migration
  def self.up
    add_column :bookmarks, :bookmark_text, :string
  end

  def self.down
    remove_column :bookmarks, :bookmark_text
  end
end
