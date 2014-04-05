class ActsAsTaggableMigration < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :name, :null => false
    end
    
    create_table :taggings do |t|
      t.integer :tag_id,        :null => false
      t.integer :taggable_id,   :null => false, :references => nil
      t.string  :taggable_type, :null => false
      
      t.timestamps
    end
    
    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type]
  end
  
  def self.down
    drop_table :taggings
    drop_table :tags
  end
end
