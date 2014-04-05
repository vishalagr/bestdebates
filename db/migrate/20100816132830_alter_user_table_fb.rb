class AlterUserTableFb < ActiveRecord::Migration
  def self.up
    execute("ALTER table users  CHANGE fb_user_id fb_user_id BIGINT(20)")
  end

  def self.down
  end
end
