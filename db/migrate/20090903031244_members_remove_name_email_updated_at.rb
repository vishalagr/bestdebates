class MembersRemoveNameEmailUpdatedAt < ActiveRecord::Migration
  def self.up
    change_table :members do |t|
      t.remove :name, :email, :updated_at
    end
  end

  def self.down
    change_table :members do |t|
      t.string   :name, :email
      t.datetime :updated_at
    end
  end
end
