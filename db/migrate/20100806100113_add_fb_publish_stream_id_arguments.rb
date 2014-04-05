class AddFbPublishStreamIdArguments < ActiveRecord::Migration
  def self.up
    add_column :arguments, :fb_publish_stream_id , :string, :limit => 20
  end

  def self.down
    remove_column :arguments , :fb_publish_stream_id
  end
end
