require 'nokogiri'

class ArgumentsController < ApplicationController
  #TODO recheck protect_from_forgery's excepts
  protect_from_forgery :except => [:tooltip, :rating_pane, :rating, :rate,:search_tooltip,:drafts_tooltip,:addon_argument_create,:watching] #,:chrome_argument_create]
  
  caches_page   :rss
  cache_sweeper :rss_sweeper, :only => [:create, :destroy, :update]
  
  before_filter :login_required,                   :only => [:new,  :create, :rate, :add_tag, :report_offensive, :xml_import, :duplicate_argument, :similar_argument, :contexts,:drafts,:addon_argument_create] #,:chrome_argument_create]
  before_filter :find_debate,                      :only => [:new,  :create, :xml_import, :similar_argument]
  
  before_filter :invitation_code_check,        :only => :show
  before_filter :invite_link_check,            :only => :show
  
  before_filter :check_freezed, :only => [:new, :create, :edit, :update, :destroy, :add_tag, :tab]
  
  before_filter :argument_create_permission_check, :only => [:new,  :create, :xml_import]
  #  before_filter(:write_permission_check ,
  #    :only => [:new,:create,:update,:edit,:destroy,:tab],
  #    :if => lambda{|c|
  #      return true unless c.params[:action] == 'tab'
  #    (c.params[:tab].to_i == Argument::TABS[:reply]) ||  (c.params[:tab].to_i == Argument::TABS[:edit]) || (c.params[:tab].to_i == Argument::TABS[:delete])
  #    }
  #  )
  before_filter(
    :argument_edit_permission_check,
    :only => [:edit, :update, :destroy, :tab],
    :if   => lambda{|c| 
    return true unless c.params[:action] == 'tab' # run for all not Tab actions
     (c.params[:tab].to_i == Argument::TABS[:edit]) || (c.params[:tab].to_i == Argument::TABS[:delete])
  }
  )
  
  before_filter :contexts, :only => :tab, :if => lambda { |c|
   (c.params[:tab].to_i == Argument::TABS[:contexts])
  }
  before_filter :drafts, :only => :tab, :if => lambda { |c|
   (c.params[:tab].to_i == Argument::TABS[:drafts])
  }
  before_filter :find_argument,   :except => [:index, :new, :create, :xml_import, :similar_argument,:unsubscription,:drafts_tooltip,:addon_argument_create] #,:chrome_argument_create]
  before_filter :is_visible_for?, :only   =>  :show
  before_filter :set_title,       :only   => [:show, :edit]
  
  before_filter :can_edit_argument?,               :only => [:add_tag]
  
  skip_filter   :update_logins,   :only => :rss
  
  rescue_from ActiveRecord::RecordNotFound, :with => :argument_not_found if public_app?
  
  verify :xhr => true, :method => :get, :only => [:tab], :redirect_to => :root_url
  
  make_resourceful do
    actions :new, :show, :edit, :destroy
    belongs_to :debate
    
    before :show do
      @argument.most_accessed!
      @user = current_user if logged_in?
    end
    
    response_for :show do |format|
      format.html
      format.xml
    end
    
    before :new do
      @argument.debate  = params[:debate_id].blank? ? @argument.parent.debate : find_debate(params[:debate_id])
      find_parent
      @argument.dest_id = @argument_parent.id if @argument_parent
    end
    
    response_for :update do |format|
      format.html { redirect_to debate_url(@debate) }
    end
    
    response_for :destroy do |format|
      flash_notice = 'Argument was deleted.'
      format.html{
        flash[:notice] = flash_notice	
        redirect_to @argument.parent ? argument_url(@argument.parent) : debate_url(@argument.debate)	
      }
      format.js do
        render :update do |page|
          flash.now[:notice] = flash_notice          
          page.reload_flashes!          
          page.remove mktree_node_dom_id(@argument)
          page << "processLiRemoveChild($('#{mktree_node_dom_id(@argument.parent_id)}'))"
        end
      end
    end
  end
  
  def index
    @arguments = Argument.recent(current_user, params)
  end
  
  def subscription
    @argument.ancestors.each_with_index do |parent,i|
      subcriptions = Subscription.find(:all, :conditions => ["argument_id = ? and status = 1", parent.id])
      if !subcriptions.empty?
        subcriptions.each do |sub|
          deep = @argument.level - i    
          Delayed::Job.enqueue(SubscribeMailJob.new(parent.id,@argument.id,sub.id,@host) , 1, 5.minutes.from_now)   if deep <= sub.deep || sub.deep == 0
          #Delayed::Job.enqueue( Mailers::Debate.deliver_send_subscription_email(parent,@argument,sub,@host), 0, 5.minutes.from_now)	  if deep <= sub.deep || sub.deep == 0
          #Mailers::Debate.deliver_send_subscription_email(parent,@argument,sub,@host) if deep <= sub.deep || sub.deep == 0
        end
      end
    end   
  end
  
  def unsubscription
    begin
      Subscription.disable(params[:activation_code])
      flash[:notice] = "You are unsubscription successfully"
    rescue
      flash[:notice] = "Argument was doesn't exist for unsubscription or you are not authorized user to unsubscribe"
    end
    redirect_back_or_default(debates_url)
  end
  # Create an argument
  #   - either as a root argument i.e., which doesn't have a parent
  #   - or as a child argument to the argument with id +params[parent_id]+ 
  
  def create
    
    redirect_to(@parent ? argument_url(@parent) : debate_url(@debate)) and return if params['cancel.x']
    
    flash_success = 'Argument has been saved successfully.'
    flash_error   = 'Can\'t create a new argument'
    Argument.transaction do
      @argument = Argument.create_child(params[:argument].merge(:user => current_user, :debate => find_debate), find_parent)
      
      if @argument.errors.blank?
        @argument.set_status_from_buttons(params)
        if !@argument.draft?
          if params[:depth] && !current_user.fb_user?
            Subscription.enable(@argument,params[:depth].to_i,current_user.email,0)
          end
          
          
          subscription
          # Sending an Subscription email.
        end
        Mailers::Debate.deliver_global_admin_watching_email(@argument) if %W/production/.include?(RAILS_ENV)
        if params[:tab_action] == "1"        
          responds_to_parent do
            render :update do |page|
              flash[:notice] = flash_success

              if params[:invite_people] == '1'
                page.redirect_to(argument_invitations_path(@argument))
              else
                unless @argument.parent_id.blank?
                  rslt = ''
                  render_arguments_for([@argument], rslt)
                  page << "new Insertion.Bottom(createULforLI('#{mktree_node_dom_id(@argument.parent)}'), #{rslt.inspect});"
                  page << "var h = (window.size.innerHeight() - $('#{mktree_node_dom_id(@argument)}').clientHeight) / 2"
                  page << "processInsertLi($('#{mktree_node_dom_id(@argument)}'),('#{@argument.argument_type}'));"

                  page.visual_effect :scroll_to, mktree_node_dom_id(@argument), :duration => 2.0, :offset => "-h"
		  page.call 'expandWidth', mktree_node_dom_id(@argument) , @argument.level
                  page.visual_effect :highlight, mktree_node_dom_id(@argument), :duration => 9.9

                else
                  page.redirect_to(debate_url(@argument.debate))
                  page << toggle_div_cancel(@argument.debate)
		end
		page.call 'eraseCookie' , "argument-title#{@argument.parent_id}"		
		page.call 'initArgumentTitleFieldHandlers' , "argument-title#{@argument.parent_id}"		
                page.call 'toggle_div_cancel', argument_id(@argument, true)		
                page.call 'expandTreeToLevel', argument_ul_dom_id(@argument)
                page.call 'fMoreLessDetailsArg', more_less_link_dom_id(@argument)		
                page.replace_html arguments_errors(params[:parent_id]),""              
                page.reload_flashes!
              end
            end
          end
        else
          respond_to do |format|
            format.html { flash[:notice]     = flash_success; redirect_to(params[:invite_people] == '1' ? argument_invitations_path(@argument) : (params[:parent_id].blank? ? debate_url(@argument.debate, :anchor => view_helpers.arg_popup_dom_id(@argument)) : argument_url(@argument.parent, :anchor => view_helpers.arg_popup_dom_id(@argument))))}
            format.js   { flash.now[:notice] = flash_success }
            format.xml  { render :xml => @argument }
          end
        end
      else
        @argument = @argument.destroy_unfreeze_errors_keep  # remove unvalid record
        if params[:tab_action] == "1"
          responds_to_parent do
            render :update do |page|
              flash.now[:error] = flash_error
              page.reload_flashes!
              page.replace_html arguments_errors(params[:parent_id]), errors_box(@argument.errors)
            end
          end
        else
          respond_to do |format|
            format.html { flash.now[:error] = flash_error; render :action   => 'new'}
            format.js   { flash.now[:error] = flash_error; render :template => 'arguments/create_failed'}
            format.xml  { render :xml => @argument }
          end
        end
      end
    end
  end

  def addon_argument_create
    # There is a chance that params might not occur, and it would appear as nil.merge which raises an error. Lets handle this case.
    redirect_to root_url and return if params['cancel.x']
    Argument.transaction do
      @argument = Argument.create_child(params[:argument].merge(:user => current_user,:debate_id => 0,:argument_type => 'pro'))
      if @argument.errors.blank?
        redirect_to firefox_argument_show_argument_url(@argument)
      else
        #render :template =>'home/addon'
        redirect_to :action => 'addon' , :controller => 'home'
      end
    end    
  end
  
  

  #  def chrome_argument_create
  #    @argument = Argument.create_child(params[:argument].merge(:user => current_user,:debate_id => 0,:argument_type => 'pro'))
  #    if @argument.errors.blank?
  #      render :json => {'msg' =>"Saved the Draft sucessfully"}.to_json ,:status => 200
  #    else
  #      render :json => {'msg' => @argument.errors.full_messages.join('<br>'),'error' => 'true'}.to_json,:status => 200
  #    end
  #  end
 
  #Need exception Handling
  def firefox_argument_show
    @argument = Argument.find(params[:id])
    if !params[:show_layout]
      render :layout => "firefox_layout"
    end
  end
  
  def temp_arg_edit
    @argument = Argument.find(params[:id])
  end
  def update_temp_argument
     redirect_to user_url(current_user, :tab => 5) and return if params['cancel.x']
    begin
      @argument = Argument.find(params[:id])
      @argument.update_attributes(params[:argument])
      flash[:notice] = 'Argument was successfully Updated.'
      redirect_to user_url(current_user, :tab => 5)
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
      flash[:notice] = 'Argument was unable to update or Invalid Record.'
      redirect_to user_url(current_use , :tab => 5)
    end
  end
  
  
  def firefox_delete
    begin
      @argument = Argument.find(params[:id])
      @argument.destroy
      flash[:notice] = 'Argument was deleted.'
      redirect_to user_url(current_user, :tab => 5)
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
      flash[:notice] = 'Argument was unable to deleted or Invalid Record.'
      redirect_to user_url(current_use , :tab => 5)
    end
  end

  # Updates the argument
  def update    
    flash_success = 'Argument has been saved successfully.'
    flash_error   = 'Can\'t update the argument'
        
        if @argument.update_attributes(params[:argument])
          @argument.debate_id = params[:debate_id]
          @argument.set_status_from_buttons(params)
          if params[:tab_action] == "1"
            responds_to_parent do
              render :update do |page|
                flash[:notice] = flash_success
                # page.alert "This Msg is from Responds_to_parent"
                if params[:invite_people] == '1'
                  page.redirect_to(argument_invitations_path(@argument))
                else
                  page.redirect_to(debate_url(@argument.debate))
                end
              end
            end
          else
            respond_to do |format|
              format.html {flash[:notice]     = flash_success; redirect_to debate_url(@argument.debate, :anchor => view_helpers.arg_popup_dom_id(@argument))}
              format.js   {flash.now[:notice] = flash_success}
            end
          end
        else
          if params[:tab_action] == "1"
            responds_to_parent do
              render :update do |page|
                flash[:notice] = flash_error;
                page.reload_flashes!            
                page.insert_html :top, arguments_errors(@argument), errors_box(@argument.errors)
              end
            end
          else      
            respond_to do |format|
              format.html {flash[:error]     = flash_error; render :action   => :edit}
              format.js   {flash.now[:error] = flash_error; render :template => 'arguments/update_failed'}
            end
          end
        end
      end
      
      # Bookmarks the argument for the +current_user+
      def bookmark
        current_user.bookmark(@argument,params[:bookmark_text])
        
        respond_to do |format|  
          format.js { 
            render(:update){|page| page.bookmark_link_reload!(@argument, params[:short_title])}
          }
        end
      end
      
      def bookmark_from_email
        current_user.bookmark(@argument) if logged_in?
        redirect_to argument_url(@argument)
      end
      # Unbookmarks the argument for the +current_user+
      def unbookmark
        current_user.unbookmark(@argument)
        
        respond_to do |format|  
          format.js { 
            render(:update){|page| page.bookmark_link_reload!(@argument, params[:short_title])}
          }
        end
      end
      
      # Gets the tooltip related to the +current_user+
      def tooltip
        if !@argument.parent_id.blank?
          @parent_arg = Argument.find(@argument.parent_id)
          if (@parent_arg.relation_to_thumb == "pro" && @argument.argument_type != 'pro') || (@parent_arg.relation_to_thumb != "pro" && @argument.argument_type == 'pro')
            @response =  'con'
          elsif (@parent_arg.relation_to_thumb == "pro" && @argument.argument_type == 'pro') || (@parent_arg.relation_to_thumb != "pro" && @argument.argument_type != 'pro')
            @response =  'pro'
          end
        end   
        @str , @content = @argument.parent_id.blank? ? ["in response to",@argument.debate] : (@response == 'con' ? ["argues in opposition to",@parent_arg]: ["argues in support of",@parent_arg])
        #    rating_pane # we use rating_pane for combination of rating and tooltip
        @user = current_user #we we need a @user in the view to check if the user can Edit, Delete and if the user can bookmark it or not
      end
      
      def drafts_tooltip   
        @argument   = Argument.find(params[:id])
        @user = current_user
      end
      
      def watching    
      end
      
      def search_tooltip
        @user = current_user
      end
      
      def rating
        @user = current_user
      end
      
      #  def write_permission_check
      #    unless can_create_argues?(@debate)
      #      error = 'You have\'nt access to create or  edit arguments!'
      #      respond_to do |format|
      #        format.html {flash[:error] = error; redirect_to debates_url}
      #        format.js   {
      #          render(:update){|page| flash.now[:error] = error; page.reload_flashes!}
      #        }
      #      end
      #    end
      #  end
      # Rate the argument based on three parameters --
      # clarity, accuracy and relevance
      def rate
        # TODO refactor
        @unique_id = params[:unique_id]
        
        @rating = @argument.rate!(current_user,
                                  {:clarity   => params["clarity#{@unique_id}_average"], #_rated
        :accuracy  => params["accuracy#{@unique_id}_average"],
        :relevance => params["relevance#{@unique_id}_average"]}) if can_rate_argument?(@argument)
        
        flash.now[:notice] = 'Rating Saved'	
        
        respond_to do |format|
          format.js  {}
          format.xml {render :xml => @rating}
        end
        
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
        flash.now[:error] = "Please select a choice for all parameters"
        respond_to do |format|
          format.js do
            render(:update) {|page| page.reload_flashes!}
          end
          format.xml { render :xml => @rating }
        end
      end
      
      # Publish the argument
      def publish
        @argument.publish
        flash[:notice] = 'Argument was successfully Published.'
        redirect_to argument_url(@argument)
      end	
      
      # Unpublish the argument
      def unpublish
        @argument.unpublish
        redirect_to argument_url(@argument)
      end
      
      # Adds tags given in +params[:tag]+ to the tag_list of the argument
      def add_tag
        flash_success = 'The tags were successfully added.'
        flash_error   = 'Can\'t add the tag'
        
        @argument.tag_list.add(params[:tag].split(","))
        if @argument.save
          respond_to do |format|
            format.html{flash[:notice]     = flash_success; redirect_to argument_url(@argument)}
            format.js  {flash.now[:notice] = flash_success}
            format.xml {render :xml => @debates }
          end
        else
          respond_to do |format|
            format.html{flash[:error]     = flash_error; redirect_to argument_url(@argument)}
            format.js  {flash.now[:error] = flash_error}
            format.xml {render :xml => @argument }
          end
        end
      end
      
      # Generates RSS feed of the argument and its descendants upto depth +params[:deep]+
      def rss
        @deep = (params[:deep].to_i rescue Argument::RSS_DEFAULT_DEEP) || Argument::RSS_DEFAULT_DEEP
        render :layout => false
      end
      
      # Same as rss but formats the feed in HTML and sends an email with it
      def send_email
        depth, email , daily_digest = (params[:depth].to_i), params[:email] , params[:daily_digest]    
        
        if (email =~ User::RE_EMAIL_OK) and !params[:depth].nil?
          Subscription.enable(@argument,depth,email,daily_digest)
          #Mailers::Debate.deliver_send_email(@argument, depth, email,@host)
          respond_to do |format|
            format.js do
              render :update do |page|
                flash.now[:notice] = "Watching Successful."
                page.call 'toggle_div_cancel', @argument.id if params[:close_tab] == "tab"
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
      
      # Duplicates the current argument and sends the identification_hash
      def duplicate_argument
        sim_arg = SimilarArgument.find_or_create_record(@argument)
        identification_hash = (sim_arg ? sim_arg.identification_hash : nil)
        
        render :text => identification_hash.to_s
      end
      
      # Creates a similar argument as reply to the given argument
      def similar_argument
        find_parent
        SimilarArgument.save_similar_argument(@argument_parent, params[:identification_hash], current_user)
        
        flash[:notice] = 'Successfully created the similar argument'
        redirect_to debate_path(@debate)
      rescue
        flash[:error] = 'Unable to create a similar argument. Try again'
        redirect_to debate_path(@debate)
      end
      
      # All tab actions i.e., reply, edit, etc., (listed in Argument::TABS) are
      # handled by this action/method.
      # What has to be done for each action is present in rjs (tab.rjs) corresponding to
      # this method
      def tab
      end
      
      # Report to the administrator that the argument is offensive (through email)
      def report_offensive
        Mailers::Debate.deliver_offensive_report(@argument, current_user)
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
      
      def large_image
        render :partial => 'large_image', :locals => {:argument => @argument}
      end
      
      # Response to an argument can be given in XML format in addition to normal reply.
      # Infact, an argument tree with structure can be imported.
      # The format of the allowed xml trees can be seen @ /argument/:id.xml
      def xml_import
        xml = Nokogiri::XML(params[:xml_file].read)
        
        Argument.transaction do
          recursive_insert(xml.xpath('/argument').first, params[:parent_id])
        end
        
        flash[:notice] = 'Arguments successfully imported'
        redirect_to debate_path(@debate)
      rescue => e
        flash[:error] = 'Invalid XML'
        redirect_to debate_path(@debate)
      end
      
      # Called only through ajax
      # Returns the list of arguments corresponding to the relation given
      def relations
        arguments = @argument.relations(params[:relation_type])
        
        render :partial => 'relations', :locals => {:arguments => arguments, :relation_type => params[:relation_type]}
      end
      
      private
      
      # A recursive method used by the xml_import method to insert the xml argument response
      def recursive_insert(arg, parent_id)
        
        argument = Argument.create(
      :title         => arg.xpath('./title').first.content,
      :body          => arg.xpath('./body').first.content,
      :argument_type => arg.xpath('./argument_type').first.content,
      :debate        => @debate,
      :draft         => false,
      :user          => current_user
        )
        argument.move_to_child_of(parent_id.to_i)
        
        arg.xpath('./child_args/argument').each do |child|
          recursive_insert(child, argument.id)
        end
      end
      
      # Checks the visibility of the argument to the +current_user+
      def is_visible_for?
        redirect_to(root_url) unless find_argument.visible_to?(current_user)
      end
      
      # Finds the parent argument if its id is supplied through +params[:parent_id]+
      def find_parent
        arg = @argument  # Preserve @argument !! It'll be overridden by find_argument()
        @argument_parent ||= find_argument(params[:parent_id]) unless params[:parent_id].blank?
        @argument = arg
        
        @argument_parent
      end
      
      # Rating pane (rating pane in a tooltip)... not used presently.
      def rating_pane
        @debate = @argument.debate
      end
      
      # before_filter to prevent unauthorized users from creating arguments
      def argument_create_permission_check
        unless can_create_argument?(@debate)
          flash[:error] = 'You have\'nt permission to create argument'
          redirect_to @debate
        end    
      end
      
      # before_filter to prevent any non-admin user from making any changes
      # to an argument which is freezed
      def check_freezed 
        @debate ||= Argument.find(params[:id]).try(:debate)
        return true unless @debate.try(:is_freezed)
        
        flash_error = 'The argument you are trying to edit belongs to a freezed debate and thus is freezed'
        
        if [:new, :create].include?(params[:action].to_sym)
          flash[:error] = flash_error
          redirect_to debate_path(@debate)
          false
        elsif [:edit, :update, :rate, :add_tag, :destroy].include?(params[:action].to_sym)
          flash[:error] = flash_error
          redirect_to argument_path(params[:id])
          false
        elsif (params[:action].to_sym == :destroy) or ((params[:action].to_sym == :tab) and ![
          Argument::TABS[:video], Argument::TABS[:bookmark],
          Argument::TABS[:watching] ].include?(params[:tab].to_i))
          
          respond_to do |format|
            flash.now[:error] = flash_error
            format.js { render(:update) {|page| page.reload_flashes!} }
          end
          false
        else
          true
        end
      end
      
      # Lists all the contexts in which the argument is used
      def contexts
        find_argument(params[:id])
        @arguments = SimilarArgument.find_similar(@argument.id)
      end
      
      def drafts
        find_argument(params[:id])
        @arguments = Argument.find(:all,:conditions => ["debate_id = 0 and draft = 1 and user_id = ?", current_user.id])
      end
      
    end
