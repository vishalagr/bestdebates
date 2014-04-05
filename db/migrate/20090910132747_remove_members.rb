class RemoveMembers < ActiveRecord::Migration
  def self.up
    drop_table :members
    
    group = Group.find_by_name('Wendi') || Group.first
    User.update_all(['group_id=?', group], :group_id => nil)
  end

  def self.down
    create_table "members", :force => true do |t|
      t.integer  "group_id",   :limit => 11
      t.integer  "user_id",    :limit => 11
      t.datetime "created_at"
    end

    add_index "members", ["group_id"], :name => "group_id"
    add_index "members", ["user_id"], :name => "user_id"
  end
end
