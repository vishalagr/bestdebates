class Facebook::DebatesController < Facebook::BaseController
  layout 'tab' , :only => 'mine'

  # ...
  # 
  def mine
    page = params[:page] || 1
    if not params[:fb_sig_profile_user].nil?
      @user = User.find_by_fb_user_id(params[:fb_sig_profile_user])
    else
      @user = current_user
    end
    if @user
      # @user = User.find(7)
      @debates_and_arguments = Dest.search_by_user_id @user.id, params[:page]
    else
      render :text => ""
    end

  end
end
