class AddColArguments < ActiveRecord::Migration
  def self.up
     add_column :arguments, :most_accessed, :integer, :default => 0
  end

  def self.down
    remove_column :arguments , :most_accessed
  end
end
