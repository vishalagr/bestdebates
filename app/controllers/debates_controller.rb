class DebatesController < ApplicationController	
   
  before_filter :login_required, :only => [:new, :create, :bookmark, :unbookmark, :report_offensive,:debate_state]	
  before_filter :admin_required , :only => [:debate_state]
  before_filter :find_debate,           :except => [:index, :new, :create, :search]

  before_filter :edit_permission_check, :only   => [:edit, :update, :destroy, :add_tag]
  before_filter :admin_required,        :only   =>  :unretire
  
  before_filter :check_freezed, :only => [:edit, :update, :destroy, :add_tag, :tab]

#  before_filter :find_public_debate, :only   => :index # TODO remove??
  before_filter :set_title,          :only   => [:show, :edit]
  
  before_filter :invitation_code_check,        :only => :show
  before_filter :invite_link_check,            :only => :show
  before_filter :debate_show_permission_check, :only => :show
  before_filter :set_featured_arguments,       :only => :index

  skip_filter :featured_debates, :only => [:tooltip, :search]
  skip_filter :update_logins, :only => [:search]

  rescue_from ActiveRecord::RecordNotFound, :with => :debate_not_found if public_app?
  
  protect_from_forgery :except => [:tooltip, :search, :create,:watching]


  # Ajax search
  def search
    @debates = Debate.sphinx_search(params[:category_id], params[:query], current_user)
    render :partial => 'debate', :collection => @debates
  end

  # Index ...
  def index
    redirect_to root_url and return if params[:retired] and !admin_user?
    
    if ['category_id', 'user_id'].include?(params[:c])
      order_by = (params[:c] == 'category_id') ? 'categories.name' : 'users.login'
    end

    order_by   = 'debates.updated_at' if params[:c] == 'updated_at'
    order_by   = 'debates.title' if params[:c] == 'title'
    order_by ||= 'debates.rating'
    order_by  += (params[:d] == 'up') ? ' ASC' : ' DESC'
    
    basic_conditions, basic_values = logged_in? ? [[], []] : [['debates.draft = ?'], [false]]
    
    basic_conditions   << 'debates.is_live = ?'
    basic_values       << (params[:retired].blank? || !admin_user?)

    if !params[:category_id].blank?
      basic_conditions << 'debates.category_id = ?'
      basic_values     << params[:category_id]
    else
      # skip 'Practice Debates' if we displaying ALL Debates
      t_conditions, t_values = Category.practice_debate_params(true)
      basic_conditions << t_conditions
      basic_values     << t_values
    end
    
    debates = Debate.all :include => [:category, :user], :conditions => [basic_conditions.join(' AND '), *basic_values], :order => order_by
    @debates = if admin_user?
                 debates
               elsif logged_in?
                 current_user.public_and_owned_in(debates)
               else
                 debates.select(&:public?)
               end
     @debates = @debates.paginate :page => params[:page], :per_page => 15
	respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @debates }
    end
  end


  # Tooltip for the debate
  def tooltip
  end
  
  def watching    
  end

  # Show the debate
  def show
    @debate.most_accessed!
    #~ if admin_user?
      #~ @debate_users = User.find(:all , :conditions =>["id in (?)", @debate.arguments.find(:all, :select => "DISTINCT (user_id) as users").collect(&:users)])
    #~ end
    respond_to do |format|
      format.html
      format.fbml
      format.xml  { render :xml => @debate }
    end
  end

   def debate_state
   if admin_user?
      @debate_users = User.find(:all ,:joins => "LEFT JOIN groups ON users.group_id = groups.id", :order => "groups.name DESC",:conditions =>["users.id in (?)", @debate.arguments.find(:all, :select => "DISTINCT (user_id) as users").collect(&:users)])
    end 
   render :layout => 'admin'   
   end

  # New debate
  def new
    @debate = current_user.debates.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @debate }
    end
  end

  # Edit the debate
  def edit
    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @debate }
    end
  end

  # Create a debate
  def create
    # TODO: recheck + refactor
    if params.keys.include?('cancel.x')
      path = (params[:debate] and params[:debate][:category_id].to_i > 1) ? debates_url(:category_id => params[:debate][:category_id]) : root_url
      redirect_to(path) and return
    end
    
    ActiveRecord::Base.transaction do
      @debate = current_user.debates.new(params[:debate])
      @debate.set_status_from_buttons(params, true)
      
      if @debate.save
        flash[:notice] = 'Debate was successfully created.'
         #if params[:post_to_twitter]
	#	@debate.debate_by_category_to_twitter(params[:twitter_username],params[:twitter_password]) if !params[:twitter_username].blank? && !params[:twitter_password].blank?
	 # end
        respond_to do |format|
          format.html { redirect_to(params[:invite_people] == '1' ? debate_invitations_path(@debate) : @debate)}
          format.xml  { render :xml => @debate, :status => :created, :location => @debate }
        end
      else
        respond_to do |format|
          format.html { render :action => "new" }
          format.xml  { render :xml => @debate.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # Update the debate
  def update    
    @debate.set_status_from_buttons(params)
    if @debate.update_attributes(params[:debate])
      if params['makepublic.x']
        flash[:notice] = 'Debate was successfully Published.'
      else
        flash[:notice] = 'Debate was successfully updated.'
      end
      
      respond_to do |format|
        format.html { redirect_to(@debate) }
        format.js   {}
        format.xml  { head :ok }
      end
    else
      respond_to do |format|
        format.html { render :action => "edit" }
        format.xml  { render :xml => @debate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Adds tags given in +params[:tag]+ to the tag_list of the debate
  # Debates belonging to the category 'Practice Debates' cannot be tagged
  def add_tag
    if @debate.practice_debate?
      flash_error = 'The debates\' tags in "Practice Debates" category can\'t be changed!'
      respond_to do |format|
        format.html{flash[:error]     = flash_error; redirect_to debate_url(@debate)}
        format.js  {flash.now[:error] = flash_error}
      end
      return false
    end

    flash_success = 'The tags was successfully added.'
    flash_error   = 'Can\'t add the tag'
    @debate.tag_list.add(params[:tag].split(","))
    if @debate.save
      respond_to do |format|
        format.html{flash[:notice]     = flash_success; redirect_to debate_url(@debate)}
        format.js  {flash.now[:notice] = flash_success}
        format.xml {render :xml => @debates }
      end
    else
      respond_to do |format|
        format.html{flash[:error]     = flash_error; redirect_to debate_url(@debate)}
        format.js  {flash.now[:error] = flash_error}
        format.xml {render :xml => @debates }
      end
    end
  end
  
  # Generates RSS feed consisting of all its arguments and their descendants upto depth +params[:deep]+
  def rss
    @deep = (params[:deep].to_i rescue Debate::RSS_DEFAULT_DEEP) || Debate::RSS_DEFAULT_DEEP
    render :layout => false
  end


  def send_email
    depth, email = (params[:depth].to_i), params[:email]

    if (email =~ User::RE_EMAIL_OK) and !params[:depth].nil?
      Subscription.enableDebate(@debate,depth,email,params[:daily_digest])
      #Mailers::Debate.deliver_debate_send_email(@debate, depth, email,@host)
      respond_to do |format|
        format.js do
          render :update do |page|
            flash.now[:notice] = "Watching Successful."
            page.call 'toggle_div_cancel', @debate.id if params[:close_tab] == "tab"
            page.reload_flashes!
          end
        end
      end
    else
      respond_to do |format|
        format.js do
          render :update do |page|
            flash.now[:error] = "Invalid email address"
            page.reload_flashes!
          end
        end
      end
    end
  end
  # All tab actions i.e., reply, edit, etc., (listed in Debate::TABS) are
  # handled by this action/method.
  # What has to be done for each action is present in rjs (tab.rjs) corresponding to
  # this method
  def tab
  end

  # Destroys the argument record
  def destroy
    @debate.retire! #retire, don't destroy
    flash[:notice] = 'Debate was retired!'
    
    respond_to do |format|
      format.html { redirect_to(debates_url) }
      format.xml  { head :ok }
    end
  end  
  	
  # Bookmarks the debate for the +current_user+
	def bookmark
    current_user.bookmark(@debate , params[:bookmark_text])
    
    respond_to do |format|  
      format.js { 
        render(:update){|page| page.bookmark_link_reload!(@debate, params[:short_title])}
      }
    end
	end
	
  # Unbookmarks the debate for the +current_user+
	def unbookmark
    current_user.unbookmark(@debate)
    
    respond_to do |format|  
      format.js { 
        render(:update){|page| page.bookmark_link_reload!(@debate, params[:short_title])}
      }
    end
	end
	 
  # Report to the administrator that the argument is offensive (through email)
  def report_offensive
    Mailers::Debate.deliver_offensive_report(@debate, current_user)
    respond_to do |format|
      format.js do
        render :update do |page|
          flash.now[:notice] = "Thank You. This has been reported to our administrative review"
          page.reload_flashes!
        end
      end
    end
  rescue
    respond_to do |format|
      format.js do
        render :update do |page|
          flash.now[:error] = "Couldn't report as offensive. Contact your administrator"
          page.reload_flashes!
        end
      end
    end
  end
	
  private
  
  # Not used anywhere. Change this if it is.
  def find_public_debate
    find_debate(nil, true)
  end
  
  # Finds the category from +params[:category_id]+
  def set_category
    @category = params[:category_id].blank? ? nil : Category.find(params[:category_id])
  end
  
  # Finds featured arguments which are then used to display in all the pages
  def set_featured_arguments
    set_category
    @debate_of_the_day = @category ? @category.debates.of_the_day.first : Debate.of_the_day.first
    @best_pro_argument = Argument.best_by_type_and_category('pro', @category)
    @best_con_argument = Argument.best_by_type_and_category('con', @category)
  end
  
  # before_filter to prevent unauthorized users from editing debates
  def edit_permission_check
    unless can_edit_debate?(@debate)
      error = 'You have\'nt access to edit debate!'
      respond_to do |format|
        format.html {flash[:error] = error; redirect_to debates_url}
        format.js   {
          render(:update){|page| flash.now[:error] = error; page.reload_flashes!}
        }
      end
    end
  end
  
  # TODO to refactor a mathods that use the bellow and remove it
  def sort_order(default)
    "#{default.to_s.gsub(/[\s;'\"]/,'')} #{params[:d] == 'down' ? 'DESC' : 'ASC'}"
  end

  # before_filter to prevent any non-admin user from making any changes
  # to a debate which is freezed
  def check_freezed
    @debate ||= Debate.find(params[:id])
    return true unless @debate.is_freezed

    flash_error = 'The debate you are trying to edit is freezed.'

    if [:edit, :update, :destroy].include?(params[:action].to_sym)
      flash[:error] = flash_error
      redirect_to debate_path(@debate)
      false
    elsif [:destroy, :add_tag].include?(params[:action].to_sym) or (
      (params[:action].to_sym == :tab) and [Debate::TABS[:tags], Debate::TABS[:edit]].include?(params[:action].to_sym)
    )

      respond_to do |format|
        flash.now[:error] = flash_error
        format.js { render(:update) {|page| page.reload_flashes!} }
      end
      false
    else
      true
    end
  end

end
