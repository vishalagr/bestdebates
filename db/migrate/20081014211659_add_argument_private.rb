class AddArgumentPrivate < ActiveRecord::Migration
  def self.up
    add_column :arguments, :private,:integer
  end

  def self.down
    remove_column :arguments, :private
  end
end
