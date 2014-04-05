class AddFavColDebates < ActiveRecord::Migration
  def self.up
     add_column :debates, :most_accessed, :integer, :default => 0
  end

  def self.down
    remove_column :debates, :most_accessed
  end
end
