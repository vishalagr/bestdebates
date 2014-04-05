class CreateMembers < ActiveRecord::Migration
  def self.up
    create_table :members, :force => true do |t|
      t.column :group_id, :integer
      t.column :user_id, :integer
      t.column :name, :string
      t.column :email, :string

      t.timestamps
    end
  end

  def self.down
    drop_table :members
  end
end
