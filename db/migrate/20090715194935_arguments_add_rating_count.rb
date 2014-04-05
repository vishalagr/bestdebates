class ArgumentsAddRatingCount < ActiveRecord::Migration
  def self.up
    add_column :arguments, :ratings_count, :integer
    Argument.update_all 'score = 0', :score => nil    
    Argument.all.each do |a|
      a.update_attribute :ratings_count, a.ratings.count
    end
  end

  def self.down
    remove_column :arguments, :ratings_count
  end
end
