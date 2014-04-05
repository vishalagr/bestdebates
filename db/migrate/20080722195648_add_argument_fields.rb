class AddArgumentFields < ActiveRecord::Migration
  def self.up
		add_column :arguments, :clarification, :string
		add_column :arguments, :evidence, :string
		add_column :arguments, :reasoning, :string
  end

  def self.down
		remove_column :arguments, :clarification
		remove_column :arguments, :evidence
		remove_column :arguments, :reasoning
  end
end
