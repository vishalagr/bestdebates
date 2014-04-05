class AddArgumentDefinitionId < ActiveRecord::Migration
  def self.up
    add_column :arguments, :definition_id, :integer
  end

  def self.down
    remove_column :arguments, :definition_id
  end
end
