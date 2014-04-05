class AddPolymorphicAssociationsToUserResources < ActiveRecord::Migration
  def self.up
    add_column :user_resources, :resource_type, :string
    rename_column :user_resources, :debate_id, :resource_id

    UserResource.update_all('resource_type = "Debate"', 'resource_id IS NOT NULL')
  end

  def self.down
    rename_column :user_resources, :resource_id, :debate_id
    remove_column :user_resources, :resource_type
  end
end
