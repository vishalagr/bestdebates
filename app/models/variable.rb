class Variable < ActiveRecord::Base  
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
    #"#{title} #{active} x: #{ x },q: #{ q },z: #{ z },r: #{ r },y: #{ y }"
    "#{title} #{active} , q: #{ q },z: #{ z },r: #{ r } "
  end
end
