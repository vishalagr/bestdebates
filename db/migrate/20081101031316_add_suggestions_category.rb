class AddSuggestionsCategory < ActiveRecord::Migration
  def self.up
    Category.create(:name => 'Suggestions' , :description => 'suggestions from the team') unless Category.find_by_name('Suggestions')
  end

  def self.down
 #   Category.find_by_name('Suggestions').destroy
  end
end
