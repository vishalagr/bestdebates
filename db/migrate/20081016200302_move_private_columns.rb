class MovePrivateColumns < ActiveRecord::Migration
#private, of course, is a reserved word in Ruby
  def self.up
    rename_column :arguments, :private,:priv
    rename_column :debates, :private,:priv
  end

  def self.down
   rename_column :arguments,:priv, :private
    rename_column :debates, :priv, :private
  end
end
