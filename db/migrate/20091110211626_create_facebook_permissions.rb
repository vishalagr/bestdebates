class CreateFacebookPermissions < ActiveRecord::Migration
  def self.up
    create_table :facebook_permissions, :id => false do |t|
      t.belongs_to :user

      t.boolean :status_update
      t.boolean :photo_upload
      t.boolean :sms
      t.boolean :offline_access
      t.boolean :email
      t.boolean :create_event
      t.boolean :rsvp_event
      t.boolean :publish_stream
      t.boolean :read_stream
      t.boolean :share_item
      t.boolean :create_note
      t.boolean :bookmarked
    end
  end

  def self.down
    drop_table :facebook_permissions
  end
end
