class Argument < ActiveRecord::Base
  RATINGS = {
		:accuracy => [
			['10 Accurate', 10],
			['9', 9],
			['8', 8],
			['7', 7],
			['6', 6],
			['5', 5],
			['4', 4],
			['3', 3],
			['2', 2],
			['1', 1],
			['0 Neutral', 0],
			['-1', -1],
			['-2', -2],
			['-3', -3],
			['-4', -4],
			['-5', -5],
			['-6', -6],
			['-7', -7],
			['-8', -8],
			['-9', -9],
			['-10 Inaccurate', -10]
		],
		
		:clarity => [
			['10 Clear', 10],
			['9', 9],
			['8', 8],
			['7', 7],
			['6', 6],
			['5', 5],
			['4', 4],
			['3', 3],
			['2', 2],
			['1', 1],
			['0 Unclear', 0]
		],
		
		:relevance => [
			['10 Relevant', 10],
			['9', 9],
			['8', 8],
			['7', 7],
			['6', 6],
			['5', 5],
			['4', 4],
			['3', 3],
			['2', 2],
			['1', 1],
			['0 Irrelevant', 0]
		]
	}
  
  def can_be_modified_by?(u)
    self.owner?(u)
  end

  private
  
  # Moves the argument to the child of find_new_parent
  def move!
    return unless create_new_parent?
     parent_arg = find_new_parent
    self.move_to_child_of(parent_arg)
    if parent_arg
      self.debate_id = parent_arg.debate_id
      self.children.update_all("debate_id = #{parent_arg.debate_id}")
    end
  end
  
  # before_validation
  # 
  def new_parent_check
    if create_new_parent?
      new_parent = find_new_parent
      errors.add('Incorrect',  'Argument\'s root ID') and return false unless new_parent
      
      # for nested set. allow to use .move_possible? before attributes initialize
      self[left_column_name]  ||= 0
      self[right_column_name] ||= 0
      errors.add('Impossible', ' move, target node cannot be inside moved tree') and return false unless move_possible?(new_parent)
    end
  end
  
  # Checks to create a new parent or not
  def create_new_parent?
    !dest_id.blank?
  end
  
  # Finds a new parent with +id+ +dest_id+
  def find_new_parent
    #debate.arguments.find(dest_id)
    arg = Argument.find(dest_id)
    if !arg.draft?
      arg
    elsif arg.draft? && self.draft?
      arg
    else
      nil
    end
  rescue ActiveRecord::RecordNotFound 
    nil
  end
   
  # Create link
  def create_link!
    create_link_for(@link_url) unless @link_url.blank?
  end
  
  # Create link for an argument given a url +u+
  def create_link_for(u)
    l = links.build(:url => u)
    if l.save
      @link_url = nil
      return true
    end
    
    errors.add(:link_url, "#{u} is not a valid URL, or is not responding") and return false
  end
end
