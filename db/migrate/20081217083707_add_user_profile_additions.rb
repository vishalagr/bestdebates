class AddUserProfileAdditions < ActiveRecord::Migration
  def self.up
    add_column :users, :sex, :string
    add_column :users, :show_sex, :string
    add_column :users, :birthday, :date
    add_column :users, :show_birthday, :string
    add_column :users, :hometown, :string
    add_column :users, :political_views, :string
    add_column :users, :religious_views, :string
    add_column :users, :website, :string
  end

  def self.down
    remove_column :users, :sex
    remove_column :users, :show_sex
    remove_column :users, :birthday
    remove_column :users, :show_birthday
    remove_column :users, :hometown
    remove_column :users, :political_views
    remove_column :users, :religious_views
    remove_column :users, :website
  end
end