class Indexes < ActiveRecord::Migration
  def self.up
    add_index :debates, [:is_live, :priv, :created_at]
  end

  def self.down
    remove_index :index_debates_on_is_live_and_priv_and_created_at
  end
end
