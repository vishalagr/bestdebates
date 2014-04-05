class User < ActiveRecord::Base
  class << self
    # Returns all the users whose +state+ is active
    def find_all_active
      find_in_state(:all, :active)
    end
  end

  # Returns all the public debates created by the user
  def public_debates
    debates.public.all :order => 'created_at DESC'
  end

  # Returns all the public arguments created by the user
  def public_arguments
    arguments.publics.all :order => 'created_at DESC'
  end

  # Returns all the invitations received by the user
  def invited_to
    Invitation.find_all_by_user_id(self.id).collect(&:resource) unless new_record?
  end



  # Filter the debates +debts+ to select only debates which
  # are public and visible_to? the user
  def public_and_owned_in(debts) # debates
    debts.select{|d| !d.priv? or d.visible_to?(self)}
  end

  def invitations_to
      Invitation.find_all_by_user_id(self.id,:order => "resource_type desc")
  end
end
