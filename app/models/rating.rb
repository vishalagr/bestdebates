class Rating < ActiveRecord::Base
  belongs_to :argument, :counter_cache => true
  belongs_to :user
  
  default_values :accuracy => 0, :clarity => 0, :relevance => 0
  
  validates_presence_of :user_id, :argument_id
  
  validates_numericality_of :clarity, :relevance, :greater_than_or_equal_to => 0,   :less_than_or_equal_to => 10
	validates_numericality_of :accuracy,            :greater_than_or_equal_to => -10, :less_than_or_equal_to => 10
  
  # Calculates the score of the rating with 2 decimal precision
  def score
    if !RatingVariable.current.nil?
 	  xVar= RatingVariable.current.x
	  yVar= RatingVariable.current.y
    end
	  return '' unless ((accuracy.to_f + clarity.to_f + relevance.to_f ) > 0 )
    
    score = (((accuracy.to_f * xVar) + (clarity.to_f * yVar)) / (xVar + yVar)) * (relevance.to_f / 10) 
    sprintf("%.2f", score) #2-decimal precision
  end
end
