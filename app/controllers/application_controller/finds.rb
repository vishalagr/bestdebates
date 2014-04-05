class ApplicationController < ActionController::Base
  protected

  # Get invitation_code from the session or params
  def get_invitation_code
    session[:invitation_code] || params[:code]
  end
  
  # Get unique_code of the invite_link from the session or params
  def get_unique_code
    session[:unique_code] || params[:unique_id]
  end

  # Finds the invitation_code
  def find_invitation_code
    code = get_invitation_code
    code.blank? ? nil : Code.find_by_unique_hash(code)
  end
  
  # Finds the invitation_link corresponding to the unique_code
  def find_invitation_link
    code = get_unique_code
    code.blank? ? nil : InviteLink.find_by_unique_id(code)
  end

  # before_filter to find the user
  def find_user
    @user ||= User.find_by_id(params[:id])
  end
  
  # before_filter to find the debate
  def find_debate(id=nil, only_public=false)
    conds = ['id = ?']
    prms  = [id || params[:debate_id] || params[:id]]
    if only_public
      conds << 'is_live = ?'
      prms  << true
    end
    
    @debate ||= (Debate.first :conditions => [conds.join(' AND '), *prms] or raise ActiveRecord::RecordNotFound)
  end
  
  # before_filter to find the argument
  def find_argument(id=nil)
    @argument   = Argument.find(id || params[:argument_id] || params[:id])
    @debate   ||= @argument.debate
    @argument
  end
  
  # Fetch all featured_debates to display it in 'Join a topic' block
  def featured_debates
    @featured_debates = Debate.featured if show_featured_debates?
  end
  
  def featured_debates_all_pages
    @featured_debates = Debate.featured if show_featured_debates_all_pages?
  end
  
  # All Support Pages
  def support_pages
   @supportpages = SupportPage.find(:all , :order =>'page_title')
  end
  # Find the resource i.e., related argument or debate
  def find_resource
    if params[:argument_id]
      @resource_type, @resource = 'Argument', find_argument(params[:argument_id])
    elsif params[:debate_id]
      @resource_type, @resource = 'Debate', find_debate(params[:debate_id])
    end
  rescue
    static_404_page
    return
  end
end
