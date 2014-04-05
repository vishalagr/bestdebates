class UsersAddLastVisited < ActiveRecord::Migration
  def self.up
    add_column :users, :last_visited, :string
  end

  def self.down
    remove_column :users, :last_visited
  end
end
