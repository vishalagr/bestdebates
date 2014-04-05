class CreateUserDebates < ActiveRecord::Migration
  def self.up
    create_table :user_debates do |t|
      t.belongs_to :user
      t.belongs_to :debate
      t.boolean    :is_writable
      t.date       :created_at
    end
  end

  def self.down
    drop_table :user_debates
  end
end
