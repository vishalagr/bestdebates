class AddImageColumnArguments < ActiveRecord::Migration
  def self.up
    add_column :arguments, :image, :string
  end

  def self.down
    remove_column :arguments, :image, :string
  end
end