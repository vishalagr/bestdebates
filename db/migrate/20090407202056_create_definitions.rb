class CreateDefinitions < ActiveRecord::Migration
  def self.up
    create_table :definitions do |t|
      t.string :name,         :null => false
      t.string :description
      
      t.timestamps
    end
  end

  def self.down
    drop_table :definitions
  end
end
