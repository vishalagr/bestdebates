class CreateGuests < ActiveRecord::Migration
  def self.up
    create_table :guests do |t|
      t.string :email, :null => false
      t.string :unique_hash
      t.integer :invited_by, :null => false
      t.integer :user_id
      t.string :last_visited
      t.timestamp :created_at
    end

    add_index :guests, :email, :unque => true
    add_index :guests, :unique_hash, :unique => true
  end

  def self.down
    drop_table :guests
  end
end
