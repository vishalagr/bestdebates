class ModifyRatings < ActiveRecord::Migration
  def self.up
		remove_column :ratings, :civility
    remove_column :ratings, :concision
    remove_column :ratings, :validity
		
		add_column :arguments, :score, :float
  end

  def self.down
		remove_column :arguments, :score, :float
		
		add_column :ratings, :civility, :integer
		add_column :ratings, :concision, :integer
		add_column :ratings, :validity, :integer
  end
end
