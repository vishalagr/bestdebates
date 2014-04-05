class SearchController < ApplicationController  
  # List of all search results
  def index
    @results = fetch_results_for(params['search_term'])
  end
  
  # Create a search_result
  def create
    @categories = []
    if (search_term = params[:search_result]['search'])
      @results = fetch_results_for(search_term) 
      render :action => 'index'
    end
  end
  
  # ...
  def update
    @results = fetch_results_for(params['search_result']['search'])
    @categories = []
    render :action => 'index'
  end
  
  private
  
  # Searching the database for the search_term
  # either in the +body+ and +title+ of +argument+
  # or +debate+ or objects tagged with it.
  def fetch_results_for(search_term)
    if params['tag'] #limited to args, sorted differently
      @show_search_title = true
      return(SearchResult.find_args_with_tag(params['tag'])) 
    end
    
    return [] if search_term.blank?
    
    SearchResult.find(search_term, current_user)
  end
end
