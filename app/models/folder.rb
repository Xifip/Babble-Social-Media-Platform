class Folder < ActiveRecord::Base
  
  acts_as_tree
  
  attr_accessible :name
  
  belongs_to :user  
  has_many :messages, :class_name => "MessageCopy"
  
  validates :user_id, :presence => true
  validates :name, :presence => true
  
end
