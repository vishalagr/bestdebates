class VariableSetsRename < ActiveRecord::Migration
  def self.up
    rename_table 'variable_sets', 'variables'
    
    Variable.create( :title => 'Default',:x => 4, :y => 0.6, :r => 3 , :z => 0.4, :q => 1.5 )
    # fixes for an exists data
    Variable.first.update_attribute(:active, true)
    Variable.all.each{|v| v.update_attribute :active, !!v.active}
  end

  def self.down
    rename_table 'variables', 'variable_sets'
  end
end
