module ArgumentsHelper
  include Custom::RssHelper
  
  def rating_select(form, parameter, html_options = {})
    form.select(parameter, Argument::RATINGS[parameter], { :include_blank => true }, html_options)
  end
  
  def argument_type_icon(argument)
    image_tag("thumb_#{argument.relation_to_thumb == 'pro' ? "up" : "down"}.png", :id => thumb_dom_id(argument),:class => "argues_type_#{argument.relation_to_thumb}", :alt => argument.argument_type) if argument.relation_to_thumb != 'com'
  end
  def argument_own_icon(argument)
    image_tag("small-blue-star.png", :id => star_dom_id(argument),:class =>"star", :alt => "You are the author of this argument",:style=>"cursor:pointer;margin-left:-5px;") #display:block;
  end
  def use_button_icon(argument)
    image_tag("use_button_small.png" ,:id => use_dom_id(argument), :class => "right")
  end
  def author_tooltip_script(elem_id)
    <<-STR
<script type="text/javascript">
  new Tip('#{elem_id}', 'You are the author of this argument',
  {    
    hook: { target: '#{elem_id}', tip: 'bottomLeft', mouse: true },
    stem: 'bottomLeft',
    hideOn: 'mouseleave',
    hideAfter: 0.2,
    hideOthers: true,
    offset: { x: 7, y: 7},
    viewport: true
    }
  );
</script>
    STR
  end
  def argument_anti_draft_icon(argument)
    image_tag("anti_draft_icon.png", :name => anti_dom_id(argument),
      :style=>"cursor:pointer;", 
      :alt => "This argument is a draft - it is not published to the public") #display:block;
  end
   
  def anti_draft_tooltip_script(elem_id)
     <<-STR
<script type="text/javascript">
  new Tip('#{elem_id}', 'This argument is a draft - it is not published to the public',
  {
    hook: { target: 'topMiddle', tip: 'bottomLeft', mouse: true },
    stem: 'bottomLeft',
    hideOn: 'mouseleave',
    hideAfter: 0.2,
    hideOthers: true,
    viewport: true
    }
  );
</script>
    STR
  end
  def user_link_id(email)
    begin
      User.find(:first, :conditions => ["email LIKE ?",email]).id
    rescue
      nil
    end
  end
  def parentIsDraft(arg)
    begin
      argument = Argument.find(arg)
      return !argument.blank? && !argument.draft?
    rescue
      return true
    end
  end
  
  def argument_draft_notification(argument)
    argument.draft? ? 'DRAFT' : nil
  end
  def search_argument_draft_notification(argument)
    argument.draft? ? link_to('DRAFT',argument_path(argument)) : nil
  end
  def argument_show_draft_info?(argument)
    argument.draft? 
  end
  def external_link_img(options={})
    txt = 'External links'
    image_tag 'Icon_External_Link.png', {:title => txt, :alt => txt}.merge!(options)
  end
  
  def external_links_icon(argument)
    if argument.argument_links.size > 0
      id = "ExternalLink_#{argument.id}"
      link_to(
        external_link_img, '#',
        :id => id,
        :class => "external_link",
        :onclick => "openExternalLinkDiv(event, #{argument.id})"
        ) 
    end
  end
  
  def argument_display_color(argument)
    argument.argument_type == 'pro' ? "green" : "red"
  end
  
  def argument_display_score(argument)
    content_tag :div, :id => "cum_#{argument.id}" do
      argument.rated? ? sprintf("%2.2f", argument.score) : "-"
    end
  end
  
  def user_rating_score(rating)
    rating.new_record? ? '-' : rating.score
  end
  
  def rating_close_box
    link_to_function(image_tag('close.png'), 'Tips.hideAll()')
  end
  
  def observe_rated(dom_id)
    "$('#{dom_id}').observe('starbox:rated', function() {
      if($('save_rating#{unique_id}').src.indexOf('save-new')> -1)
        $('save_rating#{unique_id}').src = \"/images/save-new-rating-button-blue.png\";
      else
        $('save_rating#{unique_id}').src = \"/images/save_rating.png\";
      $('save_rating#{unique_id}').disabled = \"\";});"
  end
  
  # error's dom id for argument
  def arguments_errors(argument_or_string)
    'arguments_errors_' << (argument_or_string.is_a?(String) ? argument_or_string : argument_id(argument_or_string))
  end
  
  def argument_body(argument)
    content_tag :span, :class => "arg" do
      argument.body
    end
  end
  
  #  def arg_save_button?(arg)
  #    !arg.new_record?
  #  end
  
  def arg_save_as_draft_button?(arg)
    arg.new_record?
  end
  
  #def combo_score(argument)
  #  "#{sprintf("%.1f", argument.cascaded_score) } / #{argument.v}%"
  # end
  def ratting_score(argument)
    "#{sprintf("%.1f", argument.cascaded_score) }"
  end
  def vetting_score(argument)
    "/#{argument.v}%"
  end
  def link_to_argument(argument)
    link_to(argument.full_title, argument_url(argument), :id => arg_popup_dom_id(argument), :class => "arg_tooltip_list bold")
  end
  
  def argument_parent_hidden_field(argument)
    hidden_field_tag :parent_id, argument.parent_id || argument.dest_id
  end

  def argument_rate_form_style(buttons_in_right)
    buttons_in_right ? 'position:absolute; top:40px;  right:5px;   width:140px;' :
      'position:relative; top:-70px; right:-320px;width:140px;height:0px;'
  end

  def use_button_tooltip_script(elem_id)
    <<-STR
<script type="text/javascript">
  new Tip('#{elem_id}', 'press the "Use" button to use this argument as a Reply to the active argument',
  {
    hook: { target: 'topRight', tip: 'bottomLeft', mouse: true },
    stem: 'bottomLeft',
    hideOn: 'mouseleave',
    hideAfter: 0.2,
    hideOthers: true,
    viewport: true
    }
  );
</script>
    STR
  end
  # using argument_rate_id(argument) DOM id
  def rating_script(argument)
    <<-STR
<script type="text/javascript">
  new Tip('#{argument_rate_id(argument)}' ,
  {closeButton: true,
  hook: { target: 'bottomRight', tip: 'bottomRight' },
  viewport: true,
  hideAfter: 0.2,
  hideOn: { element: 'closeButton', event: 'click'},
    ajax: {
    url: '#{tooltip_argument_url(argument)}'
    }}
  );
</script>
    STR
  end
  
  def rating_script_top(argument)
    <<-STR
<script type="text/javascript">
  new Tip('#{argument_rate_id(argument)}' ,
  {closeButton: true,
  hook: { target: 'topRight', tip: 'leftMiddle' },
  viewport: true,
  hideAfter: 0.2,
  hideOn: { element: 'closeButton', event: 'click'},
    ajax: {
    url: '#{tooltip_argument_url(argument)}'
    }}
  );
</script>
    STR
  end
  
  def watching_script(argument_or_debate)
    if (argument_or_debate).is_a?(Argument)
      url = watching_argument_url(argument_or_debate)
    elsif (argument_or_debate).is_a?(Debate)
      url = watching_debate_url(argument_or_debate)
    end
    <<-STR
<script type="text/javascript">
  new Tip('#{watching_id(argument_or_debate)}' ,
  {closeButton: true,
  hook: { target: 'bottomRight', tip: 'rightMiddle' },
  viewport: true,
  hideAfter: 1,
  hideOn: { element: 'closeButton', event: 'click'},
    ajax: {
    url: '#{url}'
    }}
  );
</script>
    STR
  end
  
  
  def argument_tooltip_script(argument)
    <<-STR
    #{link_to_function argument.title, :href=> argument_path(argument), :onclick => 'return true', :id => arg_popup_dom_id(argument), :class =>'arg_tooltip_list'}
    STR
  end
  
  def drafts_argument_tooltip_script(argument)
    <<-STR
    #{link_to_function argument.title, :href=> firefox_argument_show_argument_path(argument, :show_layout => true), :onclick => 'return true', :id => arg_popup_dom_id(argument), :class => "draft_arg_tooltip"}
    STR
  end
  def search_argument_tooltip_script(argument)
    <<-STR
    #{link_to_function argument.title, :href=> argument_path(argument), :onclick => 'return true', :id => arg_popup_dom_id(argument) , :class =>'arg_tooltip'}
    STR
  end

  def search_author_tooltip_script(author)
    uid =  'author' << author.id.to_s
    <<-STR
    #{link_to_function author.login, :href=> user_path(author), :onclick => 'return true', :class => "auth_tooltip", :id => tooltip_user_url(author)}
    STR
  end

  def search_external_links_icon(argument)
    if argument.argument_links.size > 0
      id = "ExternalLink_#{argument.id}"
      link_to(
        external_link_img, argument_path(argument),
        :id => id        
      ) << <<-STR
<script type="text/javascript">
  new Tip('#{id}', '<div style="width:200px;font-size: 12px;">This argument has external links.</div>',{
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
  def rating_tooltip_script(elem_id)
    <<-STR
<script type="text/javascript">
  new Tip('#{elem_id}', '#{rating_tooltip_content}',
  { 
    title: 'Rating',
    hook: { target: 'topRight', tip: 'bottomLeft', mouse: true },
    stem: 'bottomLeft',
    hideOn: 'mouseleave',
    hideAfter: 0.2,
    hideOthers: true,
    viewport: true
    }
  );
</script>
    STR
  end
  def argument_content(argument)
     case argument.level
     when 0
       @length = argument.draft? ? 55 : 59
     when 1
        @length = argument.draft? ? 50 : 55
     when 2
       @length = argument.draft? ? 45 : 50
     when 3
       @length = argument.draft? ? 44 : 48
     when 4
       @length = argument.draft? ? 40 : 45
     when 5
       @length = argument.draft? ? 35 : 40
     else
        if argument.level < 25
         @length = argument.draft? ? (45 -  (2*argument.level)): (48 -  (2*argument.level))
        else
          @length = 1
        end
     end
  end

  def vetting_tooltip_script(elem_id)
    <<-STR
<script type="text/javascript">
  new Tip('#{elem_id}', '#{vetting_tooltip_content}',
  {
    title: 'Vetting Percentage',
    hook: { target: 'topRight', tip: 'bottomLeft', mouse: true },
    stem: 'bottomLeft',
    hideOn: 'mouseleave',
    hideAfter: 0.2,
    hideOthers: true,
    viewport: true
    }
  );
</script>
    STR
  end

  def rating_tooltip_content
    %Q{<div style="width:400px;font-size:8pt"><p>Combined assessment of all user&#39;s judgment&#39;s on this argument&#39;s accuracy, clarity and relevance on a scale of 1-10. </p></div>}
  end
  
  def vetting_tooltip_content
    %Q{<div style="width:400px;font-size:8pt"><p>Confidence level in the users assessment based on number of ratings, their distribution and the diversity of the raters on a scale of 1-100%.  </p> </div>}
  end
=begin
  def render_html_argument(argument, depth, current_depth,parent_arg)
    output = %Q{
    <div style="border:1px solid #DDDDDD;margin:10px 0;">
      <h3 style="text-decoration:underline">#{argument.title}</h3>
      <p>Argument <b>#{argument.argument_type == 'pro' ? 'supports' : 'negates'}</b> the premise</p>
      <p>#{argument.body}</p>
      <p>
        Author: #{argument.user ? argument.user.name : nil} <br />
        Publication Date: #{argument.created_at} <br />
        Link: <a href="#{argument_url(argument)}">#{argument.title}</a>
      </p>
    </div>
    }

    argument.children.each { |child|
      output << render_html_argument(child, depth, current_depth + 1,"")
    } if (depth == Argument::RSS_UNLIMITED_DEEP or current_depth < depth) and argument.children.size > 0
    output
  end
=end
  
  def render_html_argument(argument, depth, current_depth,parent_arg)
    output = %Q{
    <div style="border:1px solid #DDDDDD;margin:10px 0;">
     #{render :partial => 'arguments/body_email' , :locals => {:debate => argument.debate , :argument => argument,:parent_arg => parent_arg} }
    </div>
    }

    argument.children.each { |child|
      output << render_html_argument(child, depth, current_depth + 1,"")
    } if (depth == Argument::RSS_UNLIMITED_DEEP or current_depth < depth) and argument.children.size > 0
    output
  end

  def render_html_arguments(argument, depth)
    output = ''
    argument.children.each { |child| output << render_html_argument(child, depth, 1,child.parent) }
    output
  end

  def render_html_debate_arguments(debate, depth)
    output = ''
    first_level_args = debate.arguments.select {|arg| !arg.parent_id}
    first_level_args.each { |arg| output <<  render_html_argument(arg, depth,1,debate) }
    output
  end

  def generate_xml(xml, argument)
    xml.title argument.title
    xml.body argument.body
    xml.argument_type argument.argument_type
    xml.bg_color argument.bg_color
  end

  def export_to_xml(xml, argument)
    xml.argument do
      generate_xml(xml, argument)

      xml.child_args do
        argument.children.each do |child_arg|
          export_to_xml(xml, child_arg)
        end
      end
    end
  end
end
