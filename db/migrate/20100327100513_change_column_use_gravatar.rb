class ChangeColumnUseGravatar < ActiveRecord::Migration
  def self.up
    change_column :users, :use_gravatar, :boolean, :default => true, :null => false
  end

  def self.down
  end
end
