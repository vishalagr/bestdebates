class DebateTwitterAccount < ActiveRecord::Base
  belongs_to :debate
  belongs_to :twitter_account

  class << self
    def create_or_update(attributes,id)
      debate_twitter = find(:first , :conditions => ["debate_id = ?", id])
      if !debate_twitter.blank?
        debate_twitter.update_attributes(attributes)
      else
        debate_twitter = DebateTwitterAccount.new(attributes)
        debate_twitter.save
      end
      debate_twitter
    end
  end
end
