class Invitation < ActiveRecord::Base
  default_value_for :is_writable, false
  
  belongs_to :resource, :polymorphic => true
  belongs_to :group
  belongs_to :message
  belongs_to :user
  belongs_to :invitor, :class_name => 'User', :foreign_key => 'invitor_id'

  has_one :code, :dependent => :destroy
  
  validates_presence_of :resource, :resource_type, :invitor_id
  validates_format_of   :email, 
                        :with    => Authentication::RE_EMAIL_OK, 
                        :message => Authentication::MSG_EMAIL_BAD, 
                        :if  => proc{|o| o.user_id.blank?}
  
#  attr_accessor :message

  # CHECK THIS METHOD
  # it is not used anywhere in the app
  # only invite the member who not invited to that debate
  # TODO recheck + refactor!!
  def self.invite_groups(groups, debate)
    invs = {}
    # use :select so after insert to db it does not cash.
    Invitation.all(:conditions => ['debate_id = ? AND group_id in (?) AND true', debate.id, groups]).each do |inv|
      invs[inv.group_id] = [] unless invs[inv.group_id]
      invs[inv.group_id][inv.member_id] = true
    end

    sql = []
    groups.each do |group|
      group_id = group.id
      group.members.each do |member|
        sql << "(#{debate_id}, #{group_id}, #{member.id})" unless invs[group_id] and invs[group_id][member.id]
      end
    end
    
    unless sql.empty?
      sql = 'INSERT INTO invitations(debate_id, group_id, member_id) VALUES ' + sql.join(',')
      ActiveRecord::Base.connection.execute(sql)
    end

    # then it should send emails
    invitations = Invitation.all :include => :member, :conditions => ['debate_id = ? AND group_id in (?)', debate_id, groups]
    invitations.each do |inv|
      Mailers::Debate.deliver_invitation(invitor, debate, guest, self)
    end
    
    invitations
  end
  
  # Returns
  #   the +body+ of the +message+ of the invitation if present
  #   a default message 'No message provided' if no associated message is present
  def message_body
    self.message ? message.body : 'No message provided'
  end

  # Checks whether the invitation is ever visited
  # i.e., its +last_visited+ attribute is not nil
  def visited?
    last_visited?
  end
  
  # Sets the +last_visited+ attribute to current time
  def visited
    self.last_visited = Time.now
  end
  
  # Visits the invitation and saves it
  def visited!
    visited
    save!
  end
  
  # Checks whether the invitation is a guest invitation
  #   An invitation can be sent to an existing user or a new user (guest)
  #   If it is sent to an existing user, then the user's user_id is stored
  #   Else the user's email address is stored
  def guest?
    !self.email.blank? && self.user_id.blank?
  end
  
  # Adds the given user +u+ to the list of joined_users of the invitation's resource
  def connect!(u) # user
    raise ActiveRecord::RecordNotFound, 'invalid given user' unless valid_user?(u)
    
    self.class.transaction do
      self.update_attributes :user => u
      resource.joined_users.add!(self)
      self.destroy
    end
  end

  # To constantize the :resource_type
  #def resource_type
  #  res_type = self.read_attribute(:resource_type)
  #  res_type.to_s.constantize if res_type
  #end

  protected
  
  # +after_create+ callback
  def after_create
    create_code unless code
  end
end
