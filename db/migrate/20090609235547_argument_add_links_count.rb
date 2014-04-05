class ArgumentAddLinksCount < ActiveRecord::Migration
  def self.up
    add_column :arguments, :links_count, :integer, :default => 0
    Argument.all.each{|a| a.update_attribute :links_count, a.links.size}
  end

  def self.down
    remove_column :arguments, :links_count
  end
end
