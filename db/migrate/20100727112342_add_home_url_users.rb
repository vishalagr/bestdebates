class AddHomeUrlUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :home_url, :string , :limit => 510
  end

  def self.down
    remove_column :users, :home_url
  end
end
