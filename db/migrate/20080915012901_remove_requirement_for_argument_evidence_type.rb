class RemoveRequirementForArgumentEvidenceType < ActiveRecord::Migration
  def self.up
    change_column :arguments, :evidence_type, :integer, {:null => true}
  end

  def self.down
    change_column :arguments, :evidence_type, :integer, {:null => false}
  end
end
