class CreateLogins < ActiveRecord::Migration
  def self.up
    create_table :logins do |t|
      t.timestamps
      t.string     :name 
      t.string     :sessid
    end
  end

  def self.down
    drop_table :logins
  end
end
