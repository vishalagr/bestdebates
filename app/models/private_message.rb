class PrivateMessage < ActiveRecord::Base
  acts_as_nested_set
  
  after_create {
    |record|
    if record.root_id.nil? 
      record.root_id = record.id
      record.save!
    end
  }
  
  belongs_to :author, :class_name => "User"
  has_many :private_message_copies
  has_many :replies, :class_name => "PrivateMessage", :foreign_key => "root_id"
  belongs_to :root, :class_name => "PrivateMessage"
  
  before_create :copy_recipients, :store_in_outbox_or_recur  
  attr_accessor :parent_msg, :to_users, :alert_email
  #attr_accessible :subject, :body, :msg_type, :msg_id
  validates_presence_of :subject
  
  validates_each :to_users do
    |record,attr,value|
    not_found = []
    value.split( /\s*,\s*/ ).each do
      |recipient|      
      not_found.push(recipient) if User.exists?(['login = ?', recipient]) != false
    end
    record.errors.add attr, "Recipient(s) not found : " + not_found.join(", ") if not_found.empty? 
  end
  
  def copy_recipients
    ## Using find_by_sql for union operation, in order to aviod duplicate rows with a single query users
    finder_sql = ""
    to_list =  to_users.split( /\s*,\s*/ )
    finder_sql = "select distinct(folders.id), user_id"
    finder_sql += " from users, folders"
    finder_sql += " where folders.user_id = users.id"
    finder_sql += " and folders.name = 'Inbox'"
    finder_sql += " and users.login in (#{to_list.map{|u| "'#{u}'"}.join(",")})"
    target_folders = Folder.find_by_sql(finder_sql)
    target_folders.each do |folder|     
      private_message_copies.build(
        :recipient_id => folder.user_id,
        :folder_id => folder.id
      )
    end
  end
  
  def store_in_outbox_or_recur
    return if author.nil?   
    private_message_copies.build(
      :folder_id => author.outbox.id
    )
  end
  
  def recipients
    # :include wipes out the :select, hence egar loading with :include selects everything from 
    # all the three tables.
    # :join doesn't wipe out :select, but dosen't egar load
    #private_message_copies.find(
    #  :all,
    #  :select => "users.*, private_message_copies.id, private_message_copies.folder_id, folders.id, folders.user_id",
    #  :joins => [ :folder => :user ],
    #  :conditions => ["folders.name = 'Inbox'"]
    #).collect {|msgc| msgc.folder.user }
    
    select_rcpt = "SELECT users.* FROM private_message_copies"
    select_rcpt += " INNER JOIN folders ON folders.id = private_message_copies.folder_id"
    select_rcpt += " INNER JOIN users ON users.id = folders.user_id"
    select_rcpt += " WHERE private_message_copies.private_message_id = #{self.id} AND folders.name = 'Inbox'"
    User.find_by_sql( select_rcpt )
  end
  
  def cached_recipients
    rcpt_list = self.cached_recipients_list
    if( rcpt_list.nil? || rcpt_list.blank? )
      rcpt_list = self.recipients.collect(&:login).join(",")
      self.cached_recipients_list = rcpt_list
      save_with_validation(false)
    end
    rcpt_list
  end

  ## def to get tree when there are multilpe roots
  ## based on awesome_nested_set method self_and_descendants
  def self_and_descendants_of_root
    nested_set_scope.scoped( :conditions => [
      "#{self.class.table_name}.#{quoted_left_column_name} >= ? AND #{self.class.table_name}.#{quoted_right_column_name} <= ? and root_id = ?", left, right, self.root_id
    ])
  end
  
  def ids_of_self_and_descendants_of_root
    nested_set_scope.find(
      :all,
      :select => "private_messages.id",
      :conditions => ["#{self.class.table_name}.#{quoted_left_column_name} >= ? AND #{self.class.table_name}.#{quoted_right_column_name} <= ? and root_id = ?", left, right, self.root_id]
    ).collect(&:id)
  end

  def message_category(msg_id,msg_category="Inbox")
    PrivateMessage.find_by_id(msg_id).private_message_copies.find(
      :all,
      :select => "private_message_copies.id, private_message_copies.folder_id, folders.user_id",
      :joins => [ :folder => :user ],
      :conditions => ["folders.name = '#{msg_category}'"]
      ).collect {|msgc| msgc.id }
  end
  
end
