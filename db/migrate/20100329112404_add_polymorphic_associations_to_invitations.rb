class AddPolymorphicAssociationsToInvitations < ActiveRecord::Migration
  def self.up
    add_column    :invitations, :resource_type, :string
    rename_column :invitations, :debate_id, :resource_id

    # --> Set 'resource_type' as 'debate' for all the records
    # --> Adding :default => 'debate' doesn't seem to be a wise option
    # --> Do not touch record with no associated debate
    Invitation.update_all('resource_type = "Debate"', 'resource_id IS NOT NULL')
  end

  def self.down
    rename_column :invitations, :resource_id, :debate_id
    remove_column :invitations, :resource_type
  end
end
