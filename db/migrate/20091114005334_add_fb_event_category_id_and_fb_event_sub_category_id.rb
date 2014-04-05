class AddFbEventCategoryIdAndFbEventSubCategoryId < ActiveRecord::Migration
  def self.up
    change_table :categories do |t|
      t.integer :fb_event_category_id
      t.integer :fb_event_sub_category_id
    end
    
    cats = {
      :politics =>  [ 2, 26 ], #cause     - rally
      :science  =>  [ 3, 16 ], #education - study group
      :history  =>  [ 3, 16 ], #education - study group
      :sports   => 	[ 6, 44 ]  #sports    - pep rally
    }
    
    Category.find(:all).each do |db_cat|
      cat = cats[db_cat.name.downcase.to_sym]
      if cat
        db_cat.update_attributes!(
          :fb_event_category_id     => cat[0],
          :fb_event_sub_category_id => cat[1]
        )
      end
    end
  end

  def self.down
    remove_column :categories, [:fb_event_category_id, :fb_event_sub_category_id]
  end
end
