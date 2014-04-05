module Custom::RssHelper

  def debate_feed_links(debate)
    Debate::RSS_AVAIVABLE_DEEPS.collect do |deep|
      deep_title = (deep == Debate::RSS_UNLIMITED_DEEP ? 'All' : deep)
      "#{deep} #{debate_feed_link(debate, deep, deep_title)}"
    end.join ' '
  end

  def debate_feed_link(debate, deep, deep_title)
    link_to image_tag('rss.png'), debate_rss_link_url(debate, deep), :target => :_blank, :title => deep_title
  end

  def build_debate_feed_items(debate, xml, deep)
    first_level_args = debate.arguments.select {|arg| !arg.parent_id}
    first_level_args.each { |arg| build_rss_item(xml, arg, deep, 1) }
  end

  def rss_links(argument)
    Argument::RSS_AVAIVABLE_DEEPS.collect do |deep|
      deep_title = (deep == Argument::RSS_UNLIMITED_DEEP ? 'All' : deep)
      "#{deep} #{rss_link(argument, deep, deep_title)}"
    end.join ' '
  end
  
  def rss_link(argument, deep, deep_title)
#    link_to image_tag('rss.png'), formatted_rss_argument_url(argument, :xml), :target => :_blank
    link_to image_tag('rss.png'), argument_rss_link_url(argument, deep), :target => :_blank, :title => deep_title
  end
  
  def build_rss_items(argument, xml, deep)
    argument.children.each{|child| build_rss_item(xml, child, deep, 1)}
  end
  
  def build_rss_item(xml, child, deep, current_deep=1)
    out = ''
    out << xml.item do
      xml.title(child.title)
      xml.description(rss_description(child))
      xml.author( child.user ? child.user.name.titleize : 'Anonymous' )
      xml.pubDate(child.created_at.strftime("%a, %d %b %Y %H:%M:%S %z"))
      xml.link(argument_url(child))
      xml.guid(argument_url(child))
    end
    
    child.children.each{|c| out << build_rss_item(xml, c, deep, current_deep+1)} if (deep == Argument::RSS_UNLIMITED_DEEP or current_deep < deep) and child.children.size > 0
    out
  end
  
  def rss_description(arg)
  %Q|
    <p>
      Argument <b>#{arg.relation_to_thumb == 'pro' ? 'supports' : 'negates'}</b> the debate premise<br />
      Title: #{arg.title}<br />
      Comment: #{arg.body}
    </p>
    <p>
      <b>Responds to #{arg.parent ? "parent argument:</b> #{link_to arg.parent.title, argument_url(arg.parent)}" : "debate:</b> #{link_to arg.debate.title, debate_url(arg.debate)}"}
    </p>
  |
  end
end
