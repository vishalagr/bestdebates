class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.column  :argument_id,     :integer
      t.column  :deep,            :integer
      t.column  :email,           :string
      t.column  :status,          :boolean, :default => false
      t.column  :activation_code, :string, :limit => 40
      t.timestamps
    end    
  end

  def self.down
    drop_table :subscriptions
  end
end
