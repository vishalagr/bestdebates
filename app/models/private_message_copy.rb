class PrivateMessageCopy < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 20
  
  belongs_to :private_message
  belongs_to :folder
  
  delegate   :author, :created_at, :subject, :body, :root_id, :to => :private_message
  require 'active_record/version'
  include AASM
  
  aasm_column :status
  aasm_initial_state :unread
  aasm_state :unread
  aasm_state :read
  
  aasm_event :mark_as_read do
    transitions :to => :read, :from => [:unread]
  end
  
  aasm_event :mark_as_unread do
    transitions :to => :unread, :from => [:read]
  end
  
  def recipients
    self.private_message.recipients
  end

  def cached_recipients
    self.private_message.cached_recipients
  end
 
  def message_thread(user)
    msg_ids = self.private_message.root.ids_of_self_and_descendants_of_root
    PrivateMessageCopy.find(
      :all,
      :include => [ :private_message => :author ],
      :joins => [ :folder ],
      :conditions => ["private_message_id in (#{msg_ids.join(',')}) and folders.user_id = ?", user.id],
      :group => "private_message_id",
      :order => "private_message_copies.updated_at DESC"
    )
  end
end
