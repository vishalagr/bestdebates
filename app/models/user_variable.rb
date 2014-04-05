class UserVariable < ActiveRecord::Base
	validates_presence_of  :title,:a,:b,:c,:d,:e,:f,:g,:h,:i,:j,:k,:l,:m,:n,:o,:p,:q,:r
  class << self
    # Returns the variable with title 'Default'
    def default
      find_by_title 'Default'
    end

    # Returns the variable which is active
    def current
      find_by_active(true)
    end
  end

  # Returns the details (concatenated string of all attributes and values) of the variable
  def details
    "#{title} #{active} a: #{ a },b: #{ b },c: #{ c },d: #{ d },e: #{ e} , f: #{ f },g: #{ g },h: #{ h },i: #{i },j: #{ j} , k: #{ k },l: #{ l },m: #{ m },n: #{n },o: #{ o} , p: #{ p },q: #{q },r: #{ r}"
  end
end
