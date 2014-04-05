class AddSupportCategory < ActiveRecord::Migration
  def self.up
    Category.create(:name => 'Support' , :description => 'support issues') unless  Category.find_by_name('Support')
  end

  def self.down
   # Category.find_by_name('Support').destroy
  end
end
