module Custom::ProfileHelper
  # TODO maybe move it to model logick?
  def profile_user_name(user)
    return '' unless user.is_a?(User)

    if user.fb_user?
      fd_name_tag(user)
    elsif user.using_open_id?
      !!user.name ? user.name.capitalize_words : 'openID user'
    else
      user.name.capitalize_words
    end
  end
  
  def profile_debates_arguments_title(name, user)
    name << ' ' << (the_same_user?(user) ? 'I Created' : '') << ':'
  end
  
  def profile_private_time
    '%b %d, %Y'
  end
  
  def profile_public_time
    '%b. %Y'
  end
  
  def profile_debate_argument_time(debate_argument, user)
    debate_argument.created_at.strftime(the_same_user?(user) ? profile_private_time : profile_public_time)
  end
  
  def profile_debates_list(user, title, debates_array)
    return '' if debates_array.blank?
    
    (content_tag :div, :class => "mypage-listings" do
      content_tag(:h3, title) << 
      debates_array.collect do |debate|#@user.writable_authored_debates
        content_tag :dl do
          content_tag(:dd, debate_title(debate), :class => "name") << 
          content_tag(:dd, profile_debate_argument_time(debate, user))
        end
      end.join
    end) << '<br style="clear:both;"/><br />'
  end

  def render_profile_arguments(user, arguments)
    arguments.map do |arg|
      content_tag('dl') do
        content_tag('dd', :class => 'name') do
          link_to_argument(arg)
        end + \
        content_tag('dd') do
          profile_debate_argument_time(arg, user)
        end
      end
    end.join
  end

  def render_profile_debates_list(user)
    return 'No Debates' unless user.public_debates.size > 0

    if the_same_user?(@user) or admin_user?
      profile_debates_list(@user, 'Public Debates', @user.public_debates)
    else
      profile_debates_list(@user, profile_debates_arguments_title('Debates', @user), user_debates(@user))
    end
  end

  def render_profile_private_debates_list(user)
   return 'No Debates' unless user.debates.count > 0
     if the_same_user?(@user) or admin_user?
     profile_debates_list(
        @user, 'Private Debates / Drafts',
        @user.debates.reject {|deb| deb.public? and deb.is_live == 1}
      )
    end
  end
  
  def render_profile_arguments_list(user)
    return 'No Arguments' unless user.public_arguments.size > 0

    if the_same_user?(user) or admin_user?
      content_tag(:h3) do
        'Public Arguments'
      end + \
      render_profile_arguments(user, user.public_arguments) 
    else
      content_tag(:h3) do
        profile_debates_arguments_title('Arguments', user)
      end + \
      render_profile_arguments(user, user_arguments(user))
    end
  end
  
   def render_profile_private_arguments_list(user)
    return 'No Arguments' unless user.arguments.count > 0

    if the_same_user?(user) or admin_user?      
      content_tag(:h3) do
        'Draft Arguments'
      end + \
      render_profile_arguments(user, user.arguments.select {|a| a.draft == 1 && a.debate_id != 0})
    end
  end
end
