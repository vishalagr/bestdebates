class CreateArguments < ActiveRecord::Migration
  def self.up
    create_table :arguments do |t|
      t.references  :debate, 		:null => false
      t.references  :user, 			:null => false
      t.string      :argument_type, 	:null => false
      t.string      :title, 					:null => false
      t.text        :body, 						:null => false
      t.string      :evidence_type, 	:null => false
      t.string      :link
      t.integer     :root_id, 			:references => :arguments
      t.integer     :parent_id, 		:references => :arguments
      t.integer     :lft
      t.integer     :rgt
      t.integer     :depth

      t.timestamps
    end
  end

  def self.down
    drop_table :arguments
  end
end
