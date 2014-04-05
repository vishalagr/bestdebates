class AddVideosArgumentIdIndexes < ActiveRecord::Migration
  def self.up
    add_index :videos, :argument_id
  end

  def self.down
    remove_index :videos, :argument_id
  end
end
