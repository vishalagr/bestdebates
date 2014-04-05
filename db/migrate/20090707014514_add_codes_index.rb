class AddCodesIndex < ActiveRecord::Migration
  def self.up
    add_index :codes, :unique_hash
  end

  def self.down
    remove_index :codes, :unique_hash
  end
end
