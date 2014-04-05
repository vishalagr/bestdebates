class AddArgumentDefination < ActiveRecord::Migration
  def self.up
    add_column :arguments, :is_definable, :boolean
    add_column :arguments, :defination, :string
  end

  def self.down
    remove_column :arguments, :is_definable
    remove_column :arguments, :defination
  end
end
