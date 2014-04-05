class CreateRatingVariables < ActiveRecord::Migration
  def self.up
    create_table :rating_variables do |t|
      t.string    :title,    :null => false
      t.float     :x,    :null => false
      t.float     :q,  :null => false
      t.float     :z,    :null => false
      t.float     :r,    :null => false
      t.float     :y,    :null => false
      t.integer   :is_default
      t.boolean   :active
      t.timestamps
    end
  end

  def self.down
    drop_table :rating_variables
  end
end
