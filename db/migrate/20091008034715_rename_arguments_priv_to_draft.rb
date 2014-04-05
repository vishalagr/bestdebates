class RenameArgumentsPrivToDraft < ActiveRecord::Migration
  def self.up
    rename_column :arguments, :priv, :draft
  end

  def self.down
    rename_column :arguments, :draft, :priv
  end
end
