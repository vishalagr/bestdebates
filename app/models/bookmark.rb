class Bookmark < ActiveRecord::Base

  include ActionController::UrlWriter # for `url` method

  belongs_to :user
  belongs_to :argument
  belongs_to :debate
  
  validates_presence_of :user_id
  
  class << self
    # Creates the bookmark object for the user of the object +obj+
    # Raises errors if the object is not saved
    def create_obj(obj, user,bookmark_text=nil)
      if bookmark_text == 'null'
        instance = new :user => user
      else
        instance = new :user => user , :bookmark_text => bookmark_text
      end
     
     if obj.is_a?(Argument)
       instance.argument = obj
     else
       instance.debate = obj
     end
     
     instance.save!
    end
    
    # Returns the bookmark object for the user of the object +argument_or_debate+
    def bookmark_by(user, argument_or_debate)
      field_id = argument_or_debate.is_a?(Argument) ? 'argument_id' : 'debate_id'
      
      first :conditions => ["user_id = ? AND #{field_id} = ? ", user, argument_or_debate] 
    end
  end
  
  # Returns the object that is bookmarked -- argument or debate
  def obj
    argument || debate
  end
  
  # Returns the title of the object that is bookmarked
  def title
    obj.title
  end
  
  # Returns the url of the object that is bookmarked
  def url
    argument ? argument_path(argument) : debate_path(debate)
  end
end
