require 'validates_as_uri'

class ArgumentLink < ActiveRecord::Base
  belongs_to :argument, :counter_cache => 'links_count'
    
  validates_as_uri :url
  
  before_validation :normalize_uri
  
  # Normalizes the link i.e., adds protocol to the URL if it is not already present
  # Example:-
  #   'http://www.google.com/' gives 'http://www.google.com/'
  #   'www.google.com/' gives 'http://www.google.com/'
  def normalize_uri
    self.url = Addressable::URI.heuristic_parse(self.url).normalize!.to_s if self.url
  end
end
