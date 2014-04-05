class MuchLargerArgumentBody < ActiveRecord::Migration
  def self.up
      change_column(:arguments,:body,:text)
  end

  def self.down
  end
end
