module Admin::TwitterAccountsHelper
  def check_debate_twitter(debate_id)
    return  DebateTwitterAccount.find(:first, :conditions => ["debate_id = ?", debate_id])
  end

  def check_category_twitter(category_id)
    return TwitterDebateCategory.find(:first , :conditions => ["category_id = ?", category_id])
  end
end
