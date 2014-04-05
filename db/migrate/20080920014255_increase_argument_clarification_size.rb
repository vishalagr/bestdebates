class IncreaseArgumentClarificationSize < ActiveRecord::Migration
  def self.up
    change_column(:arguments,:body,:string,:limit => 750) 
    remove_column(:arguments,:clarification) 
     #because to keep it would be obfuscation
  end

  def self.down
    add_column(:arguments,:clarification,:text) 
 end
end
