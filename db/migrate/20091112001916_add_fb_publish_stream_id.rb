class AddFbPublishStreamId < ActiveRecord::Migration
  def self.up
    add_column :debates, :fb_publish_stream_id, :string, :limit => 20
  end

  def self.down
    remove_column :debates, :fb_publish_stream_id
  end
end
