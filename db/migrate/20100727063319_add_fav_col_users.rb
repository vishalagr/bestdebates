class AddFavColUsers < ActiveRecord::Migration
  def self.up
     add_column :users, :show_favs, :boolean, :default => false
     add_column :users, :fav_sort_by, :integer, :default => 0
  end

  def self.down
    remove_column :users, :show_favs
    remove_column :users, :fav_sort_by
  end
end
