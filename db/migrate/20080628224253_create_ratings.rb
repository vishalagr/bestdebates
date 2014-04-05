class CreateRatings < ActiveRecord::Migration
  def self.up
    create_table :ratings do |t|
      t.references  :argument,    :null => false
      t.references  :user,        :null => false
      t.integer     :clarity,     :null => false
      t.integer     :civility,    :null => false
      t.integer     :concision,   :null => false
      t.integer     :relevance,   :null => false
      t.integer     :validity,    :null => false
      t.integer     :accuracy,    :null => false
      t.timestamps
    end
    
    add_index :ratings, [:argument_id, :user_id], :unique => true
  end

  def self.down
    drop_table :ratings
  end
end
