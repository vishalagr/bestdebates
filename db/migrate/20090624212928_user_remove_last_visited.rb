class UserRemoveLastVisited < ActiveRecord::Migration
  def self.up
    remove_column :users, :last_visited
  end

  def self.down
    add_column :users, :last_visited, :string
  end
end
