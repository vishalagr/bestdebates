class CreateShortcuts < ActiveRecord::Migration
  def self.up
    create_table :shortcuts do |t|
      t.column :resource_type, :string,  :null => false
      t.column :resource_url,  :string , :limit => 512
      t.column :resource_id ,  :integer
      t.column :resource_name ,:string
      t.timestamps
    end
  end

  def self.down
    drop_table :shortcuts
  end
end
