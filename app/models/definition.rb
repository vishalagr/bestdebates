class Definition < ActiveRecord::Base
  has_many :arguments, :dependent => :nullify
  
  validates_uniqueness_of :name
  validates_presence_of   :name, :description
end
