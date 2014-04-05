class Admin::DebatesController < Admin::BaseController
  before_filter :find_debate, :only => [:unretire,:debate_live_stat,:destroy]
  
  # Unretire a debate
  def unretire
    @debate.live!
    flash[:notice] = 'Debate was successfully unretired!'
    redirect_to(@debate)
  end
 

 def debate_live_stat
   begin
	   #@debate ||=  (Debate.first :conditions =>["id = ? " , params[:id]] or raise ActiveRecord::RecordNotFound)
     if @debate.is_live == 1
       @debate.retire!
       @val = "retire"
       flash_notice = 'Debate was successfully unretired!'
     else
       @debate.live!
       @val = "unretire"
       flash_notice = 'Debate was successfully retired!'
     end
     flash.now[:notice] = flash_notice
   rescue
	 end

     render :partial => "admin/home/debates_retire_status"

  end

  
  def destroy
    @debate.destroy #retire, don't destroy
    flash[:notice] = 'Debate was deleted successfully'
    
    respond_to do |format|
      format.html { redirect_to("/admin/debate_stats") }
      format.xml  { head :ok }
    end
  end  
  # In list of debates displayed to the administrator, he/she
  # can choose to retire, delte, freeze and unfreeze one or 
  # more debates
  def manage   
    if params[:debates] and params[:debates][:id]
        ActiveRecord::Base.transaction do
          case params[:commit]
          when 'Retire'
            Debate.find(params[:debates][:id]).each(&:retire!)
            flash[:notice] = 'Selected debates were retired!'
          when 'Delete'
            Debate.find(params[:debates][:id]).each(&:destroy)
            flash[:notice] = 'Selected debates were deleted!'
          when 'Freeze'
            Debate.find(params[:debates][:id]).each(&:freeze)
            flash[:notice] = 'Selected debates were freezed!'
          when 'Unfreeze'           
            Debate.find(params[:debates][:id]).each(&:unfreeze)
            flash[:notice] = 'Selected debates were unfreezed!'
          end
        end

    else
      flash[:error]= 'No debates selected!'
    end

    respond_to do |format|
      format.js {
        render(:update) {|page|  page.redirect_to debates_url(:category_id => params[:category_id]) }
      }
      format.html{ redirect_to debates_url(:category_id => params[:category_id])}
    end
   
  end
end
