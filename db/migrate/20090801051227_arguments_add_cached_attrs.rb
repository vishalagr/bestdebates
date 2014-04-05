class ArgumentsAddCachedAttrs < ActiveRecord::Migration
  def self.up
    add_column :arguments, :bg_color,          :integer, :limit => 2
    add_column :arguments, :relation_to_thumb, :string,  :limit => 3
    
    Argument.all(:conditions => {:parent_id => nil}).each do |a|
      a.update_cached_attrs!
    end
    
  end

  def self.down
    remove_column :arguments, :bg_color
    remove_column :arguments, :relation_to_thumb
  end
end
