class CreateDebates < ActiveRecord::Migration
  def self.up
    create_table :debates do |t|
      t.references  :category,    :null => false
      t.references  :user, 		    :null => false
      t.string      :title, 			:null => false
      t.string      :link
			t.string      :description, :null => false
      t.text        :body, 				:null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :debates
  end
end
