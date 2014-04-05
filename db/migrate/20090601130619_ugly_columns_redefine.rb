class UglyColumnsRedefine < ActiveRecord::Migration
  def self.up
    change_column :variable_sets, :active, :boolean
  end

  def self.down
  end
end
