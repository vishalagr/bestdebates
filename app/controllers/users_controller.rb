class UsersController < ApplicationController 
  before_filter :login_required, :only   => [:edit, :update, :auto_tweet,:auto_tweet_edit, :auto_tweet_update , :auto_tweet_create]
  before_filter :find_user,      :except => [:new, :create, :activate, :forgot_password, :reset_password, :link_user_accounts, :users_search,:message_users_mails]
  before_filter :can_edit_user?, :only => [:edit, :change_password, :edit_password]
  helper_method :user_editable?
  auto_complete_for :user, :login
  skip_filter :featured_debates, :only => [:link_user_accounts, :activate,:bookmark_text, :tooltip, :users_search,:message_users_mails]
  skip_filter :update_logins, :only => [:users_search,:message_users_mails]
  
  verify :xhr => true,                  :only => :forgot_password, :redirect_to => :debates_url
  verify :xhr => true, :method => :get, :only => [:tooltip,:bookmark_text],         :redirect_to => :root_url
  
  protect_from_forgery :except => [:tooltip,:bookmark_text]
  
  # New user page -- signup/register
  def new
    @user = User.new
    @user.use_invitation_code(find_invitation_code)
    
    # Group member signup
    @group = (params[:hash] ? Group.find_by_unique_hash(params[:hash]) : nil)
    @user.group_id = @group.id if @group
  end
  
  # Search users for invitations page
  def users_search
    str = '%' + params[:query].to_s.downcase + '%'
    @active_users = User.active.all(
      :conditions => ["LOWER(login) LIKE ? OR LOWER(name) LIKE ?", str, str],
      :order      => 'login ASC'
    )
    render :partial => 'invitations/users_select', :layout => false
  end
  
  
  
  # Show user
  def show
    user_score
    # render :text => params.inspect and return
    if params[:tab] == "watching" && !logged_in?
      flash[:notice] = "Please login,If you wish to change your subcription preferences"      
      redirect_to new_session_path(:url => store_location)
    end
    @tab_value = params[:tab].blank? ? (params[:c].blank? ? (params[:tab] || 0) : 4) : (params[:tab] || 4)
    order_by = 'arguments.title'
    
    if ['argument_id', 'debate_id'].include?(params[:c])
      order_by = (params[:c] == 'argument_id') ? 'arguments.title' : 'debates.id'
    end
    
    order_by   = 'status' if params[:c] == 'status'    
    order_by  += (params[:d] == 'up') ? ' ASC' : ' DESC'
    
    basic_conditions, basic_values = logged_in? ? [['subscriptions.email = ?','argument_id is not null'], [current_user.email]] : [[], []]
    
    
    @watchings = Subscription.all :include => [:argument, :debate], :conditions => [basic_conditions.join(' AND '), *basic_values], :order => order_by
    if logged_in?
      @arguments = Argument.find(:all,:conditions => ["debate_id = 0 and draft = 1 and user_id = ?", current_user.id])
      #    @invitations = the_same_user?(@user) ? @user.invitations.all(:include => :code) : [] # suspended as asked
      
      @folder = params[:folder] == 'inbox' ? current_user.inbox :
      params[:folder] == 'outbox' ? current_user.outbox : current_user.inbox
      options = {
      :page => params[:page],
      :include => [:private_message => :author]
      }
      params[:order] || ""
      @order = {}
      case(params[:order])
        when "received_asc"
        options.merge!( :order => "private_message_copies.updated_at ASC" )
        @order.merge!( :received => "desc")
        when "received_desc"
        options.merge!( :order => "private_message_copies.updated_at DESC" )
        @order.merge!( :received => "asc")
        when "status_asc"
        options.merge!( :order => "private_message_copies.status ASC" )
        @order.merge!( :status => "desc")
        when "status_desc"
        options.merge!( :order => "private_message_copies.status DESC" )
        @order.merge!( :status => "asc")
      else
        options.merge!( :order => "private_message_copies.updated_at DESC" )
        @order.merge!( :received => "asc")
      end
      logger.info @folder.inspect
      logger.info @folder.private_messages.inspect
      @messages = @folder.private_messages.paginate(options)
      
    end
  end
  
  # Create a user -- user registration
  #   There seems to be a problem with the emailing functionality. Emails
  #   delivered from the staging and production are being considered
  #   as spam by few spam blockers on the Internet.
  #   As of now user is directly logged in (instead of requiring activation)
  #   to bestdebates.
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    if @user.save
      #activating user to login automatically 
      if !session[:invitation_code].nil?
        @user.activate!
        self.current_user = @user
        flash[:notice] = "Registration successful! You've been signed in"
      else  
        Mailers::User.deliver_activation(@user)
        flash[:notice] = "Registration successful! For activation please check your activation email "
      end
      # Removing flash messages for popup
      
      
      # for user registration popup
      session[:just_registered] = true
      
      save_sponsor_user
      
      if code = find_invitation_code
        redirect_to self.send("#{code.invitation.resource.class.to_s.downcase}_url", code.invitation.resource) and return
      elsif il = find_invitation_link
        redirect_to self.send("#{il.resource.class.to_s.downcase}_url", il.resource) and return
      end
      support = SupportPage.find(:first,:conditions => ["page_title='1_Introduction'"])
      if !support.blank?
        redirect_to page_url(:action_page => "#{support.page_title}")
      else
        redirect_to root_url
      end
    else
      flash.now[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end
  
  # User profile edit page
  def edit
    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @user }
    end
  end
  
  # User profile update
  def update
    flash.now[:notice] = 'Your changes have been saved' if @user.update_attributes(params[:user])
    
    respond_to do |format|
      format.html { render :action => 'edit' }
      format.xml  { render :xml => @user }
    end		
  end
  
  def auto_tweet
    @user_tweet = UserTwitterAccount.find_by_user_id(current_user.id)
    if @user_tweet.blank?
      @user_twitter_account  = UserTwitterAccount.new
    else
      redirect_to auto_tweet_edit_user_path(current_user)
    end
  end
  
  def auto_tweet_edit
    @user_twitter_account  = UserTwitterAccount.find_by_user_id(current_user.id)
  end
  
  def auto_tweet_update      
    begin
      @user_twitter_account = UserTwitterAccount.find_by_user_id(current_user.id)
      @user_twitter_account.update_attributes!(params[:user_twitter_account])
      flash[:notice] = "Twitter Account Updated Successfully"
      redirect_to user_path(current_user)
    rescue
      flash[:notice] = "Unable to Update Twitter Account"
      render :action => "auto_tweet_edit"
    end
  end
  
  def auto_tweet_create     
    begin
      @user_twitter_account = UserTwitterAccount.new(params[:user_twitter_account])
      @user_twitter_account.user_id = current_user.id
      @user_twitter_account.save!
      flash[:notice] = "Twitter Account Created Successfully"
      redirect_to user_path(current_user)
    rescue
      flash[:notice] = "Unable to Create Twitter Account"
      render :action => "auto_tweet"
    end
  end
  
  def watching
    if params[:watching_id]
      sub = Subscription.find(params[:watching_id])
      if params[:status]
        sub.update_attribute(:status , 0)
        flash_success = "Successfully unsubscribed the watching email for the argument."
      elsif params[:deep]
        sub.update_attributes({:status => 1, :deep => params[:deep]})
        flash_success = "Successfully changed the deep level of watching email for the argument."
      end
      respond_to do |format|
        format.js   {render(:update) {|page| flash.now[:notice] = flash_success; page.reload_flashes!;}}
        format.html {flash[:notice] = flash_success; redirect_to user_url(params[:id])}
      end      
    end
  end
  # Link user accounts... for facebook connect
  # See User#link_fb_connect
  def link_user_accounts
    if logged_in?
      current_user.link_fb_connect(facebook_session)
    else
      User.create_from_fb_connect(facebook_session.user)
    end
    
    redirect_to root_url # TODO follow the default redirect rules
  end
  
  def user_score
    
    # of debates created
    no_of_debates = @user.debates.size
    #how many arguments are in those debates
    no_of_args_in_debates = Argument.find(:all, :conditions => ["debate_id in (?)",@user.debates.collect(&:id)])
    #how many ratings (total) within the arguments of that debate
    total_rating = Rating.find(:first,
					  :select => "count(*) as total_ratings",
					  :conditions => ["argument_id in (select id from arguments where debate_id in (select id from debates where user_id = ?) )" , @user.id])
    #how many arguments the user has authored?
    no_of_own_arguments = @user.arguments.find(:all, :conditions => ["debate_id in (?)",@user.debates.collect(&:id)])
    # how many arugments the user has rated?
    no_of_args_rated = Rating.find(:all, :conditions => ["user_id = ? and argument_id in (?)" ,@user.id,no_of_args_in_debates.collect(&:id) ])
    #how many 1st level replies have been made to their arguments?
    # how many second level replies have been made to their arguments?
    no_of_first_level_argues =  0
    no_of_sec_level_argues = 0
    
    no_of_own_arguments.each do |arg|
      sub_arg = Argument.find(:all, :conditions => ["parent_id = ?", arg.id])
      sub_arg.each do |sub|
        if sub.level == 1
          no_of_first_level_argues = no_of_first_level_argues + 1
        elsif sub.level == 2
          no_of_sec_level_argues = no_of_sec_level_argues + 1
        end
      end 
    end
    #do they have a picture on the site?
    user_pic = @user.image.blank? ? 0 : 1
    #how many arguments are they watching?
    no_of_watchings = Subscription.find(:all,:conditions => ["argument_id in (?)" ,no_of_args_in_debates.collect(&:id) ])
    #how many total ratings have other users made on their arguments
    total_ratings = Rating.find(:all,  :conditions => ["argument_id in (?)  AND user_id != ? " , @user.arguments.collect(&:id) , @user.id ])
    #what is the average total rating on their arguments?
    ratings_counts = Rating.find(:all,
						      :select => "count(*) as total_ratings",
						      :conditions => ["argument_id in (?)  AND user_id != ? " ,@user.arguments.collect(&:id) , @user.id ] , 
						      :group => "argument_id" )
    
    avg_ratings_on_own_argues = ratings_counts.size != 0 ? total_ratings.size / ratings_counts.size : 0
    #what is average total clarity rating on their arguments?
    #what is average total accuracy rating on their arguments?
    #what is average total relevance rating on their arguments?	
    avgs_on_c_a_r = Rating.find(:first , 
						     :select => "avg(clarity) as avg_clarity , avg(accuracy) as avg_accuracy , avg(relevance) as avg_relevance", 
						     :conditions => ["argument_id in (?)",@user.arguments.collect(&:id)])
    
    #how many videos have they embedded?
    no_of_videos = Video.find(:all ,  :conditions => ["argument_id in (?)",@user.arguments.collect(&:id)])
    
    #how many images have they embedded?
    no_of_images = @user.arguments.find(:all , :conditions => ["image is not null"])
    
    #how many links have they added?
    links = ArgumentLink.find(:all ,
						  :select => "count(*) as total_links_count" ,
						  :conditions => ["argument_id in (?)",@user.arguments.collect(&:id)] ,
						  :group => "argument_id" )
    
    no_of_links = 0
    links.each do |link|
      no_of_links = no_of_links + link.total_links_count.to_i
    end
    #how many tags have they added?
    no_of_tags = Tagging.find(:all , :conditions => ["taggable_id = ?", @user.id])
    
    
    # User Score Calculation Starts
    vars = UserVariable.current || UserVariable.default
    if !vars.nil?
      user_score =   (no_of_debates * vars.a) + (no_of_args_in_debates.size * vars.b) 
      
      
      user_score += (total_rating.total_ratings.to_i  *  vars.c)  if !total_rating.total_ratings.blank?
      user_score += (no_of_own_arguments.size * vars.d) + (no_of_args_rated.size * vars.e) + (no_of_first_level_argues * vars.f) + (no_of_sec_level_argues * vars.g) + (user_pic * vars.h + no_of_watchings.size * vars.i) +
       (total_ratings.size * vars.j) + (avg_ratings_on_own_argues * vars.k)
      user_score += (avgs_on_c_a_r.avg_clarity.to_i * vars.l ) if !avgs_on_c_a_r.avg_clarity.blank?
      user_score += (avgs_on_c_a_r.avg_accuracy.to_i * vars.m ) if !avgs_on_c_a_r.avg_accuracy.blank?
      user_score += (avgs_on_c_a_r.avg_relevance.to_i * vars.n ) if !avgs_on_c_a_r.avg_relevance.blank?
      user_score += (no_of_videos.size* vars.o) + (no_of_images.size * vars.p) + (no_of_links * vars.q) + (no_of_tags.size * vars.r)
    else
      user_score = 0
    end
    # User Score Calculation Ends
    
    #User Score
    @user_score = user_score	  
  end
  
  # Activate the user
  # Clicking activation link present in the activation email sent
  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
      when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "you have been successfully verified - add your voice to the conversation"
      session[:user_id] = user.id
      login_from_session
      redirect_to edit_user_path(user)
      #redirect_back_or_default(edit_user_path(user))
      when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default(root_url)
    else
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default(root_url)
    end
  end
  
  # Change password page
  def change_password
  end
  
  # TODO merge with Reset
  # Change password of the user
  def edit_password
    flash.now[:notice] = 'Your changes have been saved' if @user.update_attributes(params[:user])
    respond_to do |format|
      format.html { render :action => 'change_password' }
      format.xml  { render :xml => @debate }
    end	
  end
  
  # Forgot password page
  # An email is sent for further instructions.
  def forgot_password
    flash_success = 'We have emailed you a message with instructions for resetting your password.'
    flash_error   = 'No member record matching email address was found.'
    
    @user = User.find_by_email(params[:email])
    if @user
      @user.reset_password!
      Mailers::User.deliver_password_reset(@user)
      
      respond_to do |format|
        format.js   {render(:update) {|page| flash.now[:notice] = flash_success; page.reload_flashes!;}}
        format.html {flash[:notice] = flash_success; redirect_to signup_url}
      end
    else
      respond_to do |format|
        format.js   {render(:update) {|page| flash.now[:error] = flash_error; page.reload_flashes!;}}
        format.html {flash[:error] = flash_error; redirect_to signup_url}
      end
    end
  end
  
  # Resetting password of the user
  def reset_password
    @user = User.find_by_activation_code(params[:activation_code])
    if @user
      self.current_user = @user
      @user.activate!
      redirect_to change_password_user_path(@user)
    else
      flash[:error] = "Invalid reset-password url. Use the link provided in the reset email."
      redirect_to debates_path
    end
  end
  
  # Renders profile of a user in a tooltip
  def tooltip
    render :partial => 'tooltip', :locals => {:user => @user}
  end
  
  def bookmark_text
    @bookmark = Bookmark.find(params[:id])
    render :partial => 'bookmark_text' , :locals => {:bookmark => @bookmark}
  end
  def editbookmark
    @bookmark = Bookmark.find(params[:id]) 
  end
  def updatebookmark
    @bookmark = Bookmark.find(params[:id])
    @bookmark.update_attributes(params[:bookmark])
    redirect_to user_url(@bookmark.user)
  end
  
  def message_users_mails
    str = '%' + params[:search].to_s.downcase + '%'
    @message_users = User.active.all(
      :conditions => ["LOWER(login) LIKE ?", str],
      :order      => 'login ASC'
    )
    render :inline => "<%= auto_complete_result(@message_users, 'login') %>"
    #render :partial => 'private_messages/users_select', :layout => false
  end
  
  private
  
  # before_filter to restrict unauthorized users from editing the user profile
  def can_edit_user?
    return true if user_editable?
    
    flash[:error] = 'You don\'t have sufficient permissions to edit the user credentials'
    redirect_to user_path(@user)
  end
  
  # the_same_user?
  def user_editable?
    logged_in? and (@user == current_user) or admin_user?
  end
end
