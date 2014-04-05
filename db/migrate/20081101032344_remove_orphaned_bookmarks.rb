class RemoveOrphanedBookmarks < ActiveRecord::Migration
  def self.up
    for b in Bookmark.find(:all)
      b.destroy unless Argument.find(b.argument_id)
    end
  end

  def self.down
  end
end
