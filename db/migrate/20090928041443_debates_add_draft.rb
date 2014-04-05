class DebatesAddDraft < ActiveRecord::Migration
  def self.up
    add_column :debates, :draft, :integer
    Debate.update_all({:draft => false}, {:draft => nil})
  end

  def self.down
    remove_column :debates, :draft
  end
end
