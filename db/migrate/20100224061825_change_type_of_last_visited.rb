class ChangeTypeOfLastVisited < ActiveRecord::Migration
  def self.up
    change_column :users, :last_visited, :datetime
  end

  def self.down
    change_column :users, :last_visited, :string
  end
end
