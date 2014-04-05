class CreatePrivateMessages < ActiveRecord::Migration
  def self.up
    
    create_table :private_messages do |t|
      t.integer :author_id
      t.string :subject
      t.text :body
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.integer :root_id
      t.string :cached_recipients_list
      t.timestamps
    end
    
  end
  
  def self.down
    drop_table :private_messages
  end
end
