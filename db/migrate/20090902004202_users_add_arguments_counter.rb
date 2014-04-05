class UsersAddArgumentsCounter < ActiveRecord::Migration
  def self.up
    add_column :users, :arguments_count, :integer
    
    User.all.each do |u|
      u.update_attribute :arguments_count, u.arguments.size
    end
  end

  def self.down
    remove_column :users, :arguments_count
  end
end
