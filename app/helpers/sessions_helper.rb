module SessionsHelper
  def public_groups
    groups = Group.all :conditions => ["name != ?", 'admin']
    
    # 'None' group must be first
    none_group = nil
    groups.delete_if{|g| 
      if g.name.downcase == 'none'
        none_group = g
        true
      end
    }
    
    ([none_group] + groups).flatten.delete_if(&:nil?)
  end
end