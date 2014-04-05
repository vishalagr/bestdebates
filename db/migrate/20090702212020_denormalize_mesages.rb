class DenormalizeMesages < ActiveRecord::Migration
  def self.up    
    remove_column :messages, :created_at
    remove_column :messages, :updated_at
    
    remove_column :codes, :created_at
    remove_column :codes, :updated_at
    
    remove_column :invitations, :member_id
    remove_column :invitations, :first_visited
    remove_column :invitations, :guest_id
    
    add_column    :invitations,  :message_id, :integer
    add_column    :invitations,  :email,      :string
    
    drop_table :invitation_trackers
    drop_table :guests
  end

  def self.down
    add_column :messages, :created_at, :datetime
    add_column :messages, :updated_at, :datetime
    
    add_column :codes, :created_at, :datetime
    add_column :codes, :updated_at, :datetime
    
    add_column :invitations, :member_id,     :integer
    add_column :invitations, :first_visited, :datetime
    add_column :invitations, :guest_id,      :integer
    
    remove_column :invitations, :message_id
    remove_column :invitations, :email
    
    create_table :invitation_trackers do |t|

      t.integer :invitation_id
      t.integer :message_id
      t.boolean :is_writable
      t.timestamps
    end
    
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
end
