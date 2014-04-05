class CreateVariableSets < ActiveRecord::Migration
  def self.up
    create_table :variable_sets do |t|
      t.string     :title,    :null => false
      t.float     :x,    :null => false
      t.float     :q,  :null => false
      t.float     :z,    :null => false
      t.float     :r,    :null => false
      t.float     :y,    :null => false
      t.integer     :is_default
      t.timestamps
    end
  end

  def self.down
    drop_table :variable_sets
  end
end
