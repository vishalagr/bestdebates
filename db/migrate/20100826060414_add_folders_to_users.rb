class AddFoldersToUsers < ActiveRecord::Migration
  def self.up
    for record in User.find(:all)
    record.folders << Folder.new( :name => "Inbox" )
    record.folders << Folder.new( :name => "Outbox" )
    end
  end

  def self.down
  end
end
