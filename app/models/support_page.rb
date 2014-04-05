class SupportPage < ActiveRecord::Base
  RE_TITLE_OK     = /\A\w[\w\.\-_@]+\z/                     # ASCII, strict
  MSG_TITLE_BAD   = "use only letters, numbers, and .-_@ please."
  
  validates_presence_of :page_title, :body
  validates_format_of   :page_title,    :with => RE_TITLE_OK, :message => MSG_TITLE_BAD
end
