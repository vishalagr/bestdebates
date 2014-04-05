class Category < ActiveRecord::Base
  has_many :debates, :dependent => :nullify
  
  validates_presence_of :name
  validates_length_of   :name, :maximum => 50, :allow_blank => true
  
  validates_presence_of :description
  validates_length_of   :description, :maximum => 80, :allow_blank => true
  has_one :twitter_debate_category,  :dependent => :destroy
  

  class << self
    # Returns the 'Support' category
    def support
      find_by_name('Support')
    end
    
    # Returns the 'Practice Debate' category
    def practice_debate
      first :conditions => practice_debate_params
    end

    # Returns the parameters for 'Practice Debates' category
    def practice_debate_params(negate=false)
       condition = negate ? 'categories.name NOT LIKE ?' : 'categories.name LIKE ?'
      [condition, 'Practice Debates']
    end

    # Returns the eager loaded statistics for Categories to display for the administrator
    def stats(page_num, per_page, conditions, order_by)
      Category.paginate(
        :page       => page_num, :per_page => per_page,
        :select     => "categories.*, count(debates.id) as debates_count,
                        count(arguments.id) as arguments_count , count(ratings.id) as ratings_count",
        :joins      => "LEFT OUTER JOIN `debates` ON categories.id = debates.category_id
                        LEFT OUTER JOIN arguments on debates.id = arguments.debate_id
                        LEFT OUTER JOIN ratings on arguments.id = ratings.argument_id",
        :conditions => conditions,
        :group      => "categories.id",
        :order      => order_by
      )
    end
  end
end
