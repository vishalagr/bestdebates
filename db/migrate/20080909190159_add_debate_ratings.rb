class AddDebateRatings < ActiveRecord::Migration
  def self.up
		add_column :debates, :rating, :float
  end

  def self.down
		remove_column :debates, :rating
  end
end
