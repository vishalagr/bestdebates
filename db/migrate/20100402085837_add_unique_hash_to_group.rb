class AddUniqueHashToGroup < ActiveRecord::Migration
  def self.up
    add_column :groups, :unique_hash, :string
  end

  def self.down
    remove_column :groups, :unique_hash
  end
end
