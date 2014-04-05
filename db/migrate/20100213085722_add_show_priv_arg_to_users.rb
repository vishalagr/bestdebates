class AddShowPrivArgToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :show_priv_arg, :boolean, :default => false
  end

  def self.down
    remove_column :users, :show_priv_arg
  end
end
