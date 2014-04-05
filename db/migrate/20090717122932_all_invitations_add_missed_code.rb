class AllInvitationsAddMissedCode < ActiveRecord::Migration
  def self.up
    Invitation.all.each{|i| i.send(:after_create)}
  end

  def self.down
  end
end
