class Category < ActiveRecord::Base
  acts_as_nested_set

  before_save :capitalize_name
  
  def to_s
    name
  end
  
  def recurse &block
    block.call self, lambda{
      self.children.each do |child|
        child.recurse(&block)
      end
    }
  end
  
  def capitalize_name
    self.name.capitalize!
  end
end