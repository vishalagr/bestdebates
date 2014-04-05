class AddHistoryCategory < ActiveRecord::Migration
  def self.up
    Category.create(:name => 'History' , :description => 'Debates about history') unless Category.find_by_name('History')
  end

  def self.down
  #  Category.find_by_name('History').destroy #if we did this, it would mess up the db potentially
  end
end
