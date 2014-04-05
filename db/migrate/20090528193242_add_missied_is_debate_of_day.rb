class AddMissiedIsDebateOfDay < ActiveRecord::Migration
  def self.up
    add_column :debates, :is_debate_of_day, :boolean, :default => true
  end

  def self.down
    remove_column :debates, :is_debate_of_day
  end
end
