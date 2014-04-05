class AddColSubscription < ActiveRecord::Migration
  def self.up
    add_column :subscriptions , :daily_digest , :integer , :default => 0
  end

  def self.down
    remove_column :subscriptions , :daily_digest
  end
end
