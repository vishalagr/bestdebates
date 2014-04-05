module DebatesHelper
  def render_arguments_for(list, rslt, options = {})
    return if list.nil? or list.empty?
    
    args = list.select{|e| e and e.visible_to?(current_user)}
    if options[:order_by]
      args = args.sort{|a, b| (b.score || 0) <=> (a.score || 0)}
      #TODO: finish that up
    end
    parent_html_id = options[:parent_html_id] || ''
    
    args.each do |a|
      a.root_argument_id = options[:root_argument_id]
      
      if options[:only_parent_of].nil? || check_parent(options[:only_parent_of], a)
        a.html_id = parent_html_id + '_' + a.id.to_s
        options[:parent_html_id] = a.html_id
        rslt << "<li id=\"#{mktree_node_dom_id(a)}\" class=\"#{a.argument_type}\" negates_parent='#{a.negates_parent?}'>" #'<li>' # html_id
        rslt << render(:partial => 'debates/argument', :locals => {:argument => a, :options => options})
        children = a.children_visible_to(current_user)
        if !children.empty? and (options[:only_parent_of].nil? || check_parent(options[:only_parent_of], a))
          options[:only_parent_of] && check_parent(options[:only_parent_of], a)
          rslt << "<ul id='#{argument_ul_dom_id(a)}'>"
          render_arguments_for(children, rslt, options)
          rslt << "</ul>\n"
        end
        rslt << "</li>\n"
      end
    end
  end  
  
  def render_arguments(list,options = {})
    rslt = "<ul class=\"#{ options[:class] ?  options[:class] : 'mktree' }\" id=\"#{ options[:name] ?  options[:name] : 'argument_tree' }\" id='children_tree'>"
    render_arguments_for(list, rslt, options)
    rslt << "</ul>\n\n"
    rslt
  end
  
  def check_parent(child, parent)
    child.parent == parent ? true : child.parent.nil? ? false : check_parent(child.parent, parent)
  end
  
  def render_scripts_for(list,rslt,options = {})
    return if list.nil? or list.empty?
    args = list.select {|e| e and e.visible_to?(current_user)}
    args.each do |a|
      if options[:only_parent_of].nil? || check_parent(options[:only_parent_of], a)
        rslt << argument_tooltip_script(a)
        render_scripts_for(a.children, rslt, options) if !a.children.empty? && (options[:only_parent_of].nil? || check_parent(options[:only_parent_of], a))
      end
    end
  end	
  
  def item_link_for(thing, options = {})
	  case thing
          when Argument
            link_to h(thing.title), debate_argument_path(thing.debate, thing, options)
          when Debate
            link_to h(thing.title), debate_path(thing, options)
          else
            "No item link: #{thing.class.name}"
          end
  end
  
  def verbose_link_name(type = :argument)
    "Show #{type.to_s.capitalize} Full Text"
  end
  
  #http://garbageburrito.com/blog/entry/447/rails-super-cool-simple-column-sorting
  def sort_link(title, column, options = {}, sort_defalut = 'up', html_options = {})
    condition = options[:unless] if options.has_key?(:unless)
    sort_dir  = (params[:c] == column.to_s && params[:d] == sort_defalut) ? sort_defalut == 'up' ? 'down' : 'up' : sort_defalut
    link_to_unless(condition, title, request.parameters.merge({:c => column, :d => sort_dir}), html_options)
  end
  
  def debate_argument_bg(argument, options,page,id)
    if page == "debates"
      options[:white_bg] ? Argument::BG_COLORS[:white] : argument.bg_color
    elsif page == "arguments"      
      begin
      arg = Argument.find(:first, :conditions => ["id = ?",id])
      argument.argument_type == 'pro' ?  "corner-gray-green" : (argument.argument_type == 'con' ? "corner-gray-red" : "corner-gray-blue")
      rescue
        argument.argument_type == 'pro' ?  "corner-gray-green" : (argument.argument_type == 'con' ? "corner-gray-red" : "corner-gray-blue")
      end      
    end
  end
  
  def debate_body(debate)
    content_tag :span, :class => "arg", :style => "line-height:20px;" do
      debate.body
    end
  end
  
  def debate_type(debate)
    if debate.is_freezed
      "Freezed"
    elsif !debate.is_live?
      "Retired"
    elsif debate.draft?
      'Draft'
    elsif debate.priv? 
      'Private'
    else
      'Public'
    end
  end
  
  def debate_form_save_buttons(debate)
    save_button            = button_submit_save
    save_as_draft_button   = image_submit_tag 'save_as_draft.png',           :class => 'left publish-button', :name => "savedraft",  :style => 'border: none;'
    save_as_publish_button = image_submit_tag 'Pub-for-public-deb-blu.gif',  :class => 'left publish-button', :name => "publish",    :style => 'border: none;'
    save_as_private_button = image_submit_tag 'Pub-for-private-deb-grn.gif', :class => 'left publish-button', :name => "unpublish" , :style => 'border: none;'
    make_public            = image_submit_tag 'make_public.jpg', :class => 'left', :name => "makepublic", :style => 'border: none;'
    if debate.new_record? || debate.draft?
      [save_as_publish_button, save_as_private_button,save_as_draft_button].join
    elsif debate.priv?
      [save_button,make_public].join
    else 
      save_button
    end
  end
  
  def debate_show_private_info?(debate)
    debate.priv? && debate.can_be_modified_by?(current_user)
  end
  
  def debate_show_draft_info?(debate)
    debate.draft? && debate.can_be_modified_by?(current_user)
  end

  def debate_tooltip_script(debate)
    <<-STR
<script type="text/javascript">
	new Tip('#{debate_dom_id(debate)}', {
    closeButton: true,
	  width: 350,
    hook: { tip: 'topLeft', mouse: true },
    viewport: true,
    fixed: true,
    stem: 'topLeft',
    hideOn: { element: 'closeButton', event: 'click'},
    hideAfter: 0.2,
    hideOthers: true,
    ajax: {url: '#{tooltip_debate_url(debate)}' }
  });
</script>
STR
  end
  
  def question_mark_help_tooltip(arg_id)
    <<-STR
      <script type="text/javascript">
        new Tip('question-mark#{arg_id}', '<div style="width:537px;font-size: 11.5px;"><span>The green #{image_tag 'bullet-green.gif', :class => 'tooltip-thumb-down' ,:style=>'vertical-align:bottom'} indicates that the argument affirms its immediate parent argument.</span><br/><br style="margin-bottom:1px" /><span> The red #{image_tag 'bullet-red.gif', :class => 'tooltip-thumb-down' ,:style=>'vertical-align:bottom'} indicates that the argument negates its immediate parent argument.</span><br style="margin-bottom:4px" /><span>The blue #{image_tag 'bullet-blue.gif', :class => 'tooltip-thumb-down' ,:style=>'vertical-align:bottom'} indicates this argument comments on its parent argument.</span><br/><br style="margin-bottom:1px" />The plus sign #{image_tag 'plus-red.gif', :class => 'tooltip-plus-minus' ,:style=>'vertical-align:bottom' } #{image_tag 'plus-green.gif', :class => 'tooltip-plus-minus' ,:style=>'vertical-align:bottom' } #{image_tag 'plus-blue.gif', :class => 'tooltip-plus-minus' ,:style=>'vertical-align:bottom' } in the box indicates there are hidden sub-arguments for this argument.<br style="margin-bottom:1px" /> Clicking a plus sign will reveal the first level sub-arguments.<br style="margin-bottom:0px" /> Clicking a minus sign #{image_tag 'minus-red.gif', :class => 'tooltip-plus-minus',:style=>'vertical-align:bottom'} #{ image_tag 'minus-green.gif', :class => 'tooltip-plus-minus' ,:style=>'vertical-align:bottom' } #{image_tag 'minus-blue.gif', :class => 'tooltip-plus-minus',:style=>'vertical-align:bottom'} will hide all the levels sub-arguments.<br /><br/> The green thumb #{image_tag 'thumb_up.png', :class => 'tooltip-thumb-up' ,:style=>'vertical-align:bottom' } indicates that the argument supports the debate premise.<br style="margin-bottom:1px" />The red thumb #{image_tag 'thumb_down.png', :class => 'tooltip-thumb-down',:style=>'vertical-align:bottom' } indicates that the argument negates the debate premise. <br style="margin-bottom:6px" /> <br/><span style="background-color:#D8EECE;">A light green background indicates that the argument affirms the argument at the top of the page. </span><br style="margin-bottom:1px" /><span style="background-color:#FEF1EB;">A light red background indicates that the argument negates the argument at the top of the page.</span><br style="margin-bottom:1px" /><span style="background-color:#f2f2f2;">A light gray background indicates this argument comments on its parent argument. </span><br><br style="margin-bottom:4px" /> The Star #{image_tag("small-blue-star.png",:style=>'vertical-align:bottom')} indicates you are the author of that argument.<br style="margin-bottom:1px" />The Bookmark #{image_tag("bookmark-one.png",:style=>'vertical-align:bottom') } indicates that the argument has bookmarked.<br style="margin-bottom:3px" />The Video #{image_tag("videocam.jpg",:style=>'vertical-align:bottom')} indicates that the argument has attached video. Click on that icon to view it.<br style="margin-bottom:3px" />The Image #{image_tag("image-icon.png",:style=>'vertical-align:bottom')} indicates that the argument has an image attached. Click on that icon to view it.<br style="margin-bottom:3px" />The Link #{image_tag("Icon_External_Link.png")} indicates that the argument has external links.<br style="margin-bottom:3px" /></div>',{
          viewport: 'true',
          showOn: 'mouseover',           
          hideOn: 'mouseleave',
          hideAfter: 0.2,
          hideOthers: true,
          hook: {target: 'topLeft', tip: 'bottomRight'},
          offset: { x: 5, y: 10 },
          stem: 'bottomRight'
        });
      </script>
STR
  end

 def user_argues(user,debate)
  user.arguments.find(:all ,:conditions => ["debate_id = ?", debate.id], :order => "created_at desc")
 end

 def no_of_argues(user,debate)
  user_argues(user,debate).size
 end

 def no_of_rated_argues(user,debate)
  Rating.find(:all , :conditions => ["argument_id in (?) AND user_id = ?" , debate.arguments.collect(&:id), user.id]).size
 end

 def avg_score_of_argues(user,debate)
    Argument.find(:first, :select => "avg(score) as avg_score" , :conditions => ["debate_id = ? AND user_id = ?", debate.id,user.id]).avg_score
 end

 def avgs_ratings(user,debate)
  Rating.find(:first , :select => "avg(clarity) as avg_clarity , avg(accuracy) as avg_accuracy , avg(relevance) as avg_relevance" , :conditions => ["argument_id in (?)" ,user_argues(user,debate).collect(&:id)])
 end

def first_and_sec_level_argues(user,debate)
 #how many 1st level replies have been made to their arguments?
       # how many second level replies have been made to their arguments?
  	no_of_first_level_argues =  0
	no_of_sec_level_argues = 0
	no_of_own_arguments = user.arguments.find(:all, :conditions => ["debate_id = ?",debate.id])

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


return no_of_first_level_argues , no_of_sec_level_argues
end

def user_score(user)

	# of debates created
	no_of_debates = user.debates.size
	#how many arguments are in those debates
	no_of_args_in_debates = Argument.find(:all, :conditions => ["debate_id in (?)",user.debates.collect(&:id)])
	#how many ratings (total) within the arguments of that debate
        total_rating = Rating.find(:first,
					  :select => "count(*) as total_ratings",
					  :conditions => ["argument_id in (select id from arguments where debate_id in (select id from debates where user_id = ?) )" , user.id])
	#how many arguments the user has authored?
        no_of_own_arguments = user.arguments.find(:all, :conditions => ["debate_id in (?)",user.debates.collect(&:id)])
        # how many arugments the user has rated?
        no_of_args_rated = Rating.find(:all, :conditions => ["user_id = ? and argument_id in (?)" ,user.id,no_of_args_in_debates.collect(&:id) ])
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
	user_pic = user.image.blank? ? 0 : 1
	#how many arguments are they watching?
	no_of_watchings = Subscription.find(:all,:conditions => ["argument_id in (?)" ,no_of_args_in_debates.collect(&:id) ])
	#how many total ratings have other users made on their arguments
	total_ratings = Rating.find(:all,  :conditions => ["argument_id in (?)  AND user_id != ? " , user.arguments.collect(&:id) , user.id ])
	#what is the average total rating on their arguments?
	ratings_counts = Rating.find(:all,
						      :select => "count(*) as total_ratings",
						      :conditions => ["argument_id in (?)  AND user_id != ? " ,user.arguments.collect(&:id) , user.id ] , 
						      :group => "argument_id" )
        
	avg_ratings_on_own_argues = ratings_counts.size != 0 ? total_ratings.size / ratings_counts.size : 0
	#what is average total clarity rating on their arguments?
	#what is average total accuracy rating on their arguments?
	#what is average total relevance rating on their arguments?	
	avgs_on_c_a_r = Rating.find(:first , 
						     :select => "avg(clarity) as avg_clarity , avg(accuracy) as avg_accuracy , avg(relevance) as avg_relevance", 
						     :conditions => ["argument_id in (?)",user.arguments.collect(&:id)])
						     
	#how many videos have they embedded?
	no_of_videos = Video.find(:all ,  :conditions => ["argument_id in (?)",user.arguments.collect(&:id)])
	 
	#how many images have they embedded?
	no_of_images = user.arguments.find(:all , :conditions => ["image is not null"])
	
	#how many links have they added?
	 links = ArgumentLink.find(:all ,
						  :select => "count(*) as total_links_count" ,
						  :conditions => ["argument_id in (?)",user.arguments.collect(&:id)] ,
						  :group => "argument_id" )

	no_of_links = 0
	links.each do |link|
	  no_of_links = no_of_links + link.total_links_count.to_i
	end
	#how many tags have they added?
	no_of_tags = Tagging.find(:all , :conditions => ["taggable_id = ?", user.id])


        # User Score Calculation Starts
	vars = UserVariable.current || UserVariable.default
	
	user_score =   (no_of_debates * vars.a) + (no_of_args_in_debates.size * vars.b)
	user_score += (total_rating.total_ratings.to_i  *  vars.c)  if !total_rating.total_ratings.blank?
	user_score += (no_of_own_arguments.size * vars.d) + (no_of_args_rated.size * vars.e) + (no_of_first_level_argues * vars.f) + (no_of_sec_level_argues * vars.g) + (user_pic * vars.h + no_of_watchings.size * vars.i) +
				(total_ratings.size * vars.j) + (avg_ratings_on_own_argues * vars.k)
	user_score += (avgs_on_c_a_r.avg_clarity.to_i * vars.l ) if !avgs_on_c_a_r.avg_clarity.blank?
	user_score += (avgs_on_c_a_r.avg_accuracy.to_i * vars.m ) if !avgs_on_c_a_r.avg_accuracy.blank?
	user_score += (avgs_on_c_a_r.avg_relevance.to_i * vars.n ) if !avgs_on_c_a_r.avg_relevance.blank?
	user_score += (no_of_videos.size* vars.o) + (no_of_images.size * vars.p) + (no_of_links * vars.q) + (no_of_tags.size * vars.r)
	# User Score Calculation Ends
	
	#User Score
	user_score
end
  def thumb_tooltip(argument)
    <<-STR
        <script type="text/javascript">
            new Tip('#{ thumb_dom_id(argument) }', '<div style="width:250px;font-size: 12px;">#{argument.relation_to_thumb == 'pro' ? "This argument affrims the debate premise" : "This argument negates the debate premise"}</div>',{
            viewport: 'true',
            hideOn: 'mouseleave',
            hideAfter: 0.2,
            hideOthers: true,
            hook: {target: 'topLeft', tip: 'bottomLeft'},
            stem: 'bottomLeft'
          });
        </script>
STR
  end

def find_debate
    debate_start_now_box = Debate.find(:first,:conditions=>{:id=>159})
if !debate_start_now_box.nil?
	"#{debate_url(159)}"
else
	"#"
end	
end

#  def debate_rating_visual_display(debate)
#    content_tag :div, :style => "height:24px; position:relative; margin-left:-4px;" do
#      #image_tag "red-to-green-line.jpg",:width =>250, :style => "position:absolute;top:10px;left:85px;"
#      #image_tag 'vee.png', :style => "position:absolute;top:0px;left:#{80 + 0.25*debate.rating.to_i}px;"
#      content_tag :div, :style => "position:absolute; left:3px; top:0px;" do
#        "Rating: #{debate.rating.to_f > 0 ? sprintf("%.1f",  debate.rating.to_f) : 0}"
#      end
#    end
#  end
end
