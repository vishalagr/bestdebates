module SearchHelper
  def search_results(collection)
    collection.sort!{|a,b| a.class <=> b.class}
    passed = []
    out = ''

    collection.collect do |result|
      # TODO: most all of this tricky code should be instead in css, once the moratorium on changing it is cleared
      result = result.obj
      klass  = result.class.name.downcase.to_sym

      # TODO html refactor
      if result.is_a?(Debate)
        unless passed.include?(:debate)
          out    << '<div id="results-debates" class="results">'
          out    << '<h2>Debate:</h2>' 
          passed << :debate
        end
        out << content_tag(:div, :class => 'search-result-debate') do
          render(:partial => "shared/debate", :locals => {klass => result}) 
        end
      elsif result.is_a?(Argument)
        unless passed.include?(:arg)
          out    << '</div>' unless passed.empty?
          out    << '<div id="results-arguments" class="results">'
          out    << '<h2>Argument:</h2>'
          passed << :arg
        end
        if result.debate.is_live?
        out << content_tag(:div, :class => 'search-result-argument') do
          search_argument_tooltip_script(result)
        end
        end
      elsif result.is_a?(User)        
        unless passed.include?(:user)
          out    << '</div>' unless passed.empty?
          out    << '<div id="results-users" class="results">'
          out    << '<h2>User:</h2>'
          passed << :user
        end
        out << content_tag(:div, :class => 'search-result-tag') do
          search_author_tooltip_script(result)
        end
      else
        unless passed.include?(:tag)
          out    << '</div>' unless passed.empty?
          out    << '<div id="results-tags" class="results">'
          out    << '<h2>Tag:</h2>'
          passed << :tag
        end
        out << content_tag(:div, :class => 'search-result-tag') do
          link_to result.name.to_s, search_results_url(:tag => (h result.name.to_s))
        end
      end
    end.join
    out << '</div>' unless passed.empty?
    out
  end
end
