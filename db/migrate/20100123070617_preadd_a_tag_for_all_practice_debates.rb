class PreaddATagForAllPracticeDebates < ActiveRecord::Migration
  def self.up
    Debate.transaction do
      debates = Debate.all(:conditions => {:category_id => Category.practice_debate})
      # remove all exists taggable connections for all debates from Practice Debate category
      debates.each(&:rm_unacceptable_tags)
      debates.each(&:preset_practice_debate_tag)
    end
  end

  def self.down
  end
end
