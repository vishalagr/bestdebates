class UnconstrainBookmarks < ActiveRecord::Migration

  def self.up
  # execute "alter table bookmarks drop foreign key bookmarks_ibfk_1"
   change_column :bookmarks, :argument_id,:integer,{:null => true}
     add_column :bookmarks, :debate_id,:integer,{:null => true }
 end

  def self.down
    remove_column :bookmarks, :debate_id
  end
  
end
