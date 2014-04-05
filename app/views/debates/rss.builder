xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel{
    xml.title("Arguments for '#{@debate.title}'")
    xml.link(debate_url(@debate))
    xml.description("Arguments for '#{@debate.title}'")
    xml.language('en-us')
    build_debate_feed_items(@debate, xml, @deep)
  }
end
