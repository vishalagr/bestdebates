class CreateSimilarArguments < ActiveRecord::Migration
  def self.up
    create_table :similar_arguments do |t|
      t.integer :argument_id
      t.string  :identification_hash

      t.timestamps
    end
  end

  def self.down
    drop_table :similar_arguments
  end
end
