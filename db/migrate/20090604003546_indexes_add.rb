class IndexesAdd < ActiveRecord::Migration
  def self.up
    add_index :users, :remember_token
    add_index :categories, :name
  end

  def self.down
    remove_index :index_users_on_remember_token
    remove_index :index_categories_on_name
  end
end
