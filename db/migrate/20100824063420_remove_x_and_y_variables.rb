class RemoveXAndYVariables < ActiveRecord::Migration
  def self.up
    execute("ALTER TABLE variables DROP x")
    execute("ALTER TABLE variables DROP y")
  end

  def self.down
  end
end
