class AddTestingCategory < ActiveRecord::Migration
  def self.up
    Category.create(:name => 'Practice Debates' , :description => 'this is a test') unless  Category.find_by_name('Practice Debates')
  end

  def self.down
   # Category.find_by_name('Practice Debates').destroy
  end
end
