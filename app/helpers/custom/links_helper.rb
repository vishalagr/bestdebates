module Custom::LinksHelper
  def link_to_logout
    name = 'Sign Out'
    fb_user? ? fb_link_to_logout(name) : link_to(name, logout_path)
  end

  def tag_link(tag)
    link_to search_results_url(:tag => tag)
  end

  def link_to_category(category)
    link_to category.name, debates_url(:category_id => category.id)
  end

  def render_link(argument, link)
    content_tag :span, :id => "argument_link_#{link.id}" , :class=>"" do
      out = ''
      out << %Q{[#{
        link_to_remote(
          'DEL',
          :method  => :delete,
          :url     => argument_link_url(argument, link),
          :confirm => 'Are you sure you want to remove the link?',
          :success => "$('argument_link_#{link.id}').remove()"
        )}] &nbsp;} if can_edit_argument?(argument)

      out << link_to(link.url, link.url, :target => 'blank') <<"<br/>"
      out
    end
  end

#  def tags_links(tags, joiner=' ', &block)
#    concat(tags.collect{|tag|
#        capture link_to(tag, search_index_url(:tag => tag.name)), &block
#      }.join(joiner), block.binding
#    )
#  end
  def tags_links(tags, joiner=' ')
    tags.collect{|tag| link_to(tag, search_results_url(:tag => tag.name))}.join(joiner)
  end

  def bookmark_link(object, short_title=false)
    return nil unless bookmark_tab?

    bookmark_url, unbookmark_url = if object.is_a?(Argument)
      [bookmark_argument_url(object, :short_title => short_title), unbookmark_argument_url(object, :short_title => short_title)]
    elsif object.is_a?(Debate)
      [bookmark_debate_url(object,   :short_title => short_title), unbookmark_debate_url(object,   :short_title => short_title)]
    end

    if short_title
      content_tag :span, :id => bookmark_dom_id(object) do
        if current_user.bookmarked?(object)
          link_to("Unbookmark", unbookmark_url,
            :onclick => 'bookmarkToggle(event, this.href)',
            :id=>"un_bookmark" , :title => "#{!current_user.bookmarked_text(object).blank? ? current_user.bookmarked_text(object) : 'No bookmark text'}" ) 
        else
          link_to("Bookmark", bookmark_url, :onclick => 'bookmarkToggle(event, this.href)')
        end
      end
    else
      content_tag :div, :id => bookmark_dom_id(object) do
        if current_user.bookmarked?(object)
          "<b>Bookmark Text :</b> #{current_user.bookmarked_text(object)}  #{link_to("Unbookmark", unbookmark_url, :onclick => 'bookmarkToggle(event, this.href)')} "
        else
          "#{object.class} not bookmarked! #{link_to("Bookmark", bookmark_url, :onclick => 'bookmarkToggle(event, this.href)')}"
        end
      end
    end
  end

  def bookmark_link_reload!(object, short_title)
    page.replace_html bookmark_dom_id(object), :inline => @context.send(:bookmark_link, object, !!short_title)
  end
end
