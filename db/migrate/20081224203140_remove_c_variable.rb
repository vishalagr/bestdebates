class RemoveCVariable < ActiveRecord::Migration
  def self.up
    add_column :variable_sets,:active,:long
   end

  def self.down
     remove_column :variable_sets,:active
  end
end
