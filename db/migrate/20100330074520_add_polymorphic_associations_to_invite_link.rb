class AddPolymorphicAssociationsToInviteLink < ActiveRecord::Migration
  def self.up
    rename_column :invite_links, :debate_id, :resource_id
    add_column :invite_links, :resource_type, :string, :null => false

    # change all columns to 'Debate'
    InviteLink.update_all('resource_type = "Debate"', 'resource_id IS NOT NULL')
  end

  def self.down
    remove_column :invite_links, :resource_type
    rename_column :invite_links, :resource_id, :debate_id
  end
end
