class ComputeDebateRatings < ActiveRecord::Migration
  def self.up
    for debate in Debate.find(:all)
      debate.recalculate_rating
    end
  end

  def self.down
  end
end
