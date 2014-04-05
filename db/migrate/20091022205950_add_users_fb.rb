class AddUsersFb < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.integer :fb_user_id
      t.string  :fb_email_hash, :fb_session_key
    end
    
    User.all(:conditions => {:fb_email_hash => nil}).each do |user|
      user.update_attribute  :fb_email_hash, Facebooker::User.hash_email(user.email)
    end
  end

  def self.down
    remove_columns :users, [:fb_user_id, :fb_email_hash, :fb_session_key]
  end
end
