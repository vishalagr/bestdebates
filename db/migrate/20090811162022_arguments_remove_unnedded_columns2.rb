class ArgumentsRemoveUnneddedColumns2 < ActiveRecord::Migration
  def self.up
    change_table :arguments do |t|
      t.remove :reasoning
      t.remove :evidence
      t.remove :defination
    end
  end

  def self.down
    change_table :arguments do |t|
      t.string :reasoning, :evidence, :defination
    end
  end
end
