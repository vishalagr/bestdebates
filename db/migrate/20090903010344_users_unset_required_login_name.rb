class UsersUnsetRequiredLoginName < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.change :login, :string, :limit => 40,  :null => true
      t.change :name,  :string, :limit => 100, :null => true
    end
  end

  def self.down
    change_table :users do |t|
      t.change :login, :string, :limit => 40,  :null => false
      t.change :name,  :string, :limit => 100, :null => false
    end
  end
end
