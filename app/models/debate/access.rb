class Debate < ActiveRecord::Base
  # can user read a debate
  def visible_to?(usr)
    return true if public? # everyone can access debate if it's public
    
    # if not public:
    return false unless valid_user?(usr) # nobody can access if we can't verify user ID
    return true if can_be_read_by?(usr)  # admin and owner can always access
    
    false # is not visible
  end

  def searchable_to?(usr)   
    #bookmark = Bookmark.find(:all, :conditions => ["debate_id = ? " , self.id])
    #if !bookmark.blank?     
     #return bookmark.collect(&:user_id).include?(usr.id)           
    #end
    
    return true if public?
    # if not public:
    return false unless valid_user?(usr)
    if self.user_id != usr.id && self.draft == 1     
      return false
    else     
      return true if can_be_read_by?(usr)
    end
    
    false
  end

  # not a `Practice Debates` debate
  def not_practice_debate
    return true unless self.category
    self.category_id != Category.practice_debate.id
  end

  # Checks whether the given user +u+ is the owner of the debate
  def owner?(u)
#    return false unless valid_user?(u)
#    self.user_id == u.id or u.admin?
    return true if valid_user?(u) and self.user_id == u.id
  end
  
  # Checks whether the debate can be modified by the given user +u+
  def can_be_modified_by?(u)
    return false unless valid_user?(u)
    self.user_id == u.id or u.admin?
  end
  
  # Checks whether the debate can be invited by the given user +u+
  def can_be_invited_by?(u)
    return false unless valid_user?(u)
    self.user_id == u.id or u.admin? or self.public?
  end

  # Checks whether the debate can create invitation by the given user +u+
  def can_create_invitation?(u)
    can_be_modified_by?(u)
  end
  
  # Checks whether the debate can be read by the given user +u+
  # only read permission
  def can_be_read_by?(u)
    return true if public? or can_be_modified_by?(u)
    !!joined_users.find_by_user(u)
  end

  # Checks whether the debate can be written by the given user +u+
  def can_by_written_by?(u)
    return true if public? or can_be_modified_by?(u)
    return false unless ju = joined_users.find_by_user(u)
    ju.is_writable?
  end
end
