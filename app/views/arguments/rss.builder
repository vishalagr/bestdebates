xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel{
    xml.title("Subarguments for '#{@argument.title}'")
    xml.link(debate_url(@argument.debate))
    xml.description("Subarguments for '#{@argument.title}'")
    xml.language('en-us')
    build_rss_items(@argument, xml, @deep)
  }
end
