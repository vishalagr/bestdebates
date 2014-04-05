class AddDebatesFbEventId < ActiveRecord::Migration
  def self.up
    add_column :debates, :fb_event_id, :integer
  end

  def self.down
    remove_column :debates, :fb_event_id
  end
end
