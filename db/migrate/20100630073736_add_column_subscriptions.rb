class AddColumnSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions,:debate_id,  :integer
    Subscription.all.each do |sub|
      sub.update_attribute(:debate_id,sub.argument.debate.id)
    end
  end

  def self.down
  end
end
