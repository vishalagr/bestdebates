class CreatePrivateMessagesCopies < ActiveRecord::Migration
  def self.up
    create_table :private_message_copies do |t|
      t.integer :recipient_id
      t.integer :private_message_id
      t.integer :folder_id
      t.string  :status
      t.timestamps
    end
  end
  
  def self.down
    drop_table :private_message_copies
  end
end
