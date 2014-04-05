class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups, :force => true do |t|
      t.column :user_id, :integer
      t.column :name, :string

      t.timestamps
    end
  end

  def self.down
    drop_table :groups
  end
end
