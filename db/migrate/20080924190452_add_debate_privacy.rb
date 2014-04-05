class AddDebatePrivacy < ActiveRecord::Migration
  def self.up
    add_column :debates,:private,:integer
  end

  def self.down
   remove_column :debates,:private
  end
end
