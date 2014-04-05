# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include Custom::FlashHelper
  include Custom::DomHelper
  include Custom::TabsHelper
  include Custom::TooltipsHelper
  include Custom::LinksHelper
  include Custom::TagsFormsHelper
  include Custom::CollectionsHelper
  include Custom::ButtonsHelper
  
  # for rails 2.3.2
  def parent_layout(layout)
    @content_for_layout = self.output_buffer
    self.output_buffer = render(:file => "layouts/#{layout}")
  end

  def http_protocol( use_ssl = request.ssl? )
    (use_ssl ? "https://" : "http://")
  end
  
	def render_member_login_menu
    render :partial => logged_in? ? "/shared/member_menu" : "/shared/login_menu"
	end

  def current_user_name(user=current_user)
    user.fb_user? ? fd_name_tag(user) : user.login
  end

  def debate_title(debate)
    link_to debate.title, debate_url(debate), :id => debate_dom_id(debate),:class => "debate_tip"
  end

  def render_author(author)
    return 'Anonymous' unless author
    render :partial => 'shared/author', :locals => {:author => author}
  end
 
  def show_defaults(argument_or_debate)
    debate = argument_or_debate.is_a?(Argument) ? argument_or_debate.debate : argument_or_debate
    
    content_for :after_header do
      <<-STR
  <script type="text/javascript">
  //<![CDATA[
    addEvent(window, 'load', function(){show_default_level(#{debate.id})}, false);
    addEvent(window, 'load', function(){show_default_status(#{debate.id})}, false);
  //]]>
  </script>
  STR
    end
  end
    
  def video_icon(argument)
    if argument.video
      id = 'video_open_link_' << argument.id.to_s
      link_to(
        image_tag('videocam.jpg'),
        '#', :id => id,
        :class => "video_open_link",
        :onclick => "openVideoDiv(event, #{argument.id.to_s})"
      ) 
    end
  end
  
  def support_link
    support = SupportPage.find(:first , :conditions => ["page_title = '1_Introduction'"])
    !support.blank? ? page_url(:action_page => "#{support.page_title}") : "#"
  end

  def image_icon(argument)
    if argument.image
      id = 'image_open_link_' << argument.id.to_s
      link_to(
        image_tag('image-icon.png'),
        '#', :id => id,
        :class => "image_open_link",
        :onclick => "openImageDiv(event, #{argument.id.to_s})"
      )
    end
  end


 def search_video_icon(argument)
    if argument.video
      id = 'video_open_link_' << argument.id.to_s
      link_to(
        image_tag('videocam.jpg'),
        argument_path(argument), :id => id
      ) << <<-STR
<script type="text/javascript">
  new Tip('#{id}', '<div style="width:200px;font-size: 12px;">This argument has attached video. Click on this icon to view it.</div>',{
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
  end

 def search_image_icon(argument)
    if argument.image
      id = 'image_open_link_' << argument.id.to_s
      link_to(
        image_tag('image-icon.png'),
        argument_path(argument), :id => id
      ) << <<-STR
<script type="text/javascript">
  new Tip('#{id}', '<div style="width:200px;font-size: 12px;">This argument has an image attached to it. Click on this icon to view it.</div>',{
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
  end

  def header_content(&block)
    content_for :header, &block
  end
  
  def javascript(*args)
    header_content do
      javascript_include_tag(*args)
    end
  end
  
  def stylesheet(*args)
    header_content do
      stylesheet_link_tag(*args)
    end
  end
  
  def starbox_options
    "{stars: 10, max: 10,buttons:20, rerate: true }"
  end
  
  def the_same_user?(user)
    logged_in? and user == current_user
  end
  
  def question_mark_image(attrs={})
    image_tag 'question-mark.png', {:class => "question-mark"}.merge!(attrs)
  end

  def fckeditor_include!
    # need to load it from 'show' actions to get ability to use dom:load observer for plugin initilize
    header_content do
      !@fckeditor_included ? (@fckeditor_included = true; javascript_include_tag :fckeditor) : nil
    end
  end

  def fb_include!
    header_content do
      fb_connect_javascript_tag + 
      init_fb_connect("XFBML")
    end if include_fb_script?
  end

  def include_fb_script?
    !logged_in? or current_user.fb_user?
  end

  def favorites_sort(fav_sort_by, object)
    fav_sort_by == 1 ? "#{object}_id" : "#{object}s.most_accessed"
  end  
  
#  def method_name(id, content)
#    <<STR
#<script type="text/javascript">
#  new Tip('#{id}', 
#  '#{content}',{
#    viewport: 'true',
#    showOn: 'mouseover',
#    hideOn: false,
#    hideAfter: 1,
#    hook: {target: 'topLeft', tip: 'bottomLeft'},
#    stem: 'bottomLeft'
#  });
#</script>
#STR
#  end
end
