class ArgumentsRemoveLink < ActiveRecord::Migration
  def self.up
    remove_column :arguments, :link
  end

  def self.down
    add_column :arguments, :link, :string
  end
end
