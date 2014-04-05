class AddLoginDuration < ActiveRecord::Migration
  def self.up
    for login in Login.find(:all)
     login.destroy
    end
    add_column :logins,:duration,:integer
  end

  def self.down
     remove_column :logins,:duration
  end
end
