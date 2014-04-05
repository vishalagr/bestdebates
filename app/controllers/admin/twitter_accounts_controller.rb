class Admin::TwitterAccountsController < Admin::BaseController
  make_resourceful do
    actions :all
  end

  def manage_twitter_accounts    
    @debates = Debate.paginate(:all, :page => params[:page], :per_page => 15,:conditions => ["is_live = ?", 1], :order => ["id"])
    @debate_twitter_account = DebateTwitterAccount.new
  end
  
  def category_twitter_accounts
    @categories = Category.find(:all)
    @twitter_debate_category = TwitterDebateCategory.new
  end

  def twitter_category_create
    if params[:twitter_debate_category]
      if params[:twitter_debate_category][:twitter_account_id].blank? && params[:twitter_debate_category][:twitter_account_id_two].blank?
       redirect_to(category_twitter_accounts_url) and return
      end
    end
    msg = TwitterDebateCategory.create_or_update(params[:twitter_debate_category],params[:id])
    if "Twitter Accounts having Duplicates." == msg
      flash[:error] = msg
    else
      flash[:notice] = msg
    end
    redirect_to(category_twitter_accounts_url)
  end

  def twitter_debate_create    
    redirect_to(manage_twitter_accounts_url) and return if params[:debate_twitter_account] && params[:debate_twitter_account][:twitter_account_id].blank?
    DebateTwitterAccount.create_or_update(params[:debate_twitter_account],params[:id])    
    flash[:notice] = "Twitter Account was added successfully to the Debate."
    redirect_to(manage_twitter_accounts_url)
  end
end
