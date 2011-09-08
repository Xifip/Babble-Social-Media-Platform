class Like < ActiveRecord::Base
  attr_accessible :liked_id
  
  belongs_to :liker, :class_name => "User"
  belongs_to :liked, :class_name => "Micropost"
  
  validates :liker_id, :presence => true
  validates :liked_id, :presence => true
  
end
