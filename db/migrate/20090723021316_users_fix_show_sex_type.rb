class UsersFixShowSexType < ActiveRecord::Migration
  def self.up
    change_column :users, :show_sex,      :boolean
    change_column :users, :show_birthday, :string, :limit => 2
  end

  def self.down
    change_column :users, :show_sex,      :string
    change_column :users, :show_birthday, :string
  end
end
