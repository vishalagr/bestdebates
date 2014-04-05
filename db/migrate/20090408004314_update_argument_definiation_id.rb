class UpdateArgumentDefiniationId < ActiveRecord::Migration
  def self.up
    [['conservative', 'conservative'], ['liberal', 'liberal'], ['libertarian', 'libertarian']].each do |d|
      definition = Definition.create(:name => d[0], :description => d[1])
      Argument.update_all "definition_id = #{definition.id}",["defination = ?", d[0]]
    end
  end

  def self.down
  end
end
