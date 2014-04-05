class CreateArgumentLinks < ActiveRecord::Migration
  def self.up
    create_table :argument_links do |t|
      t.integer     :argument_id, 	:null => false
      t.string      :url, 	:null => false
      t.string      :title
    end
  #  remove_column :arguments, :url
  #  bad idea, let's keep them, for now
  end

  def self.down
    drop_table :argument_links
  #  add_column :arguments, :url,:string 
  end
end
