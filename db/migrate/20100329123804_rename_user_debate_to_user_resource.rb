class RenameUserDebateToUserResource < ActiveRecord::Migration
  def self.up
    rename_table :user_debates, :user_resources
  end

  def self.down
    rename_table :user_resources, :user_debates
  end
end
