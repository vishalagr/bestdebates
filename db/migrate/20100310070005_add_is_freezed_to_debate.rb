class AddIsFreezedToDebate < ActiveRecord::Migration
  def self.up
    add_column :debates, :is_freezed, :boolean, :default => false
  end

  def self.down
    remove_column :debates, :is_freezed
  end
end
