class Micropost < ActiveRecord::Base
  
  attr_accessible :content
  
  validates :user, :presence => true
  validates :content, :presence => true, :length => { :maximum => 200}
  
  belongs_to :user
  
  default_scope :order => 'microposts.created_at DESC'
  
end
