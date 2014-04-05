class RemoveDebateDescription < ActiveRecord::Migration
  def self.up
		remove_column :debates, :description
  end

  def self.down
		add_column :debates, :description, :string, :null => false
  end
end
