class AddLoginLoginid < ActiveRecord::Migration
  def self.up
    change_column :logins, :sessid, :text
    add_column :logins, :loginid,  :string,  :null => true
    add_column :logins, :visits,   :integer, :null => false, :default =>  1
    add_column :logins, :user_id,  :integer, :null => true

    add_index :logins, :loginid, :unique => true, :name => 'loginid_index'
  end

  def self.down
    remove_index :logins, :column => :loginid

    change_column :logins, :sessid, :string
    remove_column :logins, :loginid, :visits, :user_id
  end
end
