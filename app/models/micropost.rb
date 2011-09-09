class Micropost < ActiveRecord::Base
  
  attr_accessible :content
  
  validates :user, :presence => true
  validates :content, :presence => true, :length => { :maximum => 200}
  
  belongs_to :user
  
  #likes
  has_many :likes, :foreign_key => "liked_id", :dependent => :destroy
  has_many :likers, :through => :likes, :source => :liker, 
    :class_name => "User"
  
  default_scope :order => 'microposts.created_at DESC'
  
  scope :from_users_followed_by, lambda { |user| followed_by(user)}
  
  def likes_count 
    likes.count
  end
  
  private
  
  # Return an SQL condition for users followed by the given user. 
  # 
  # One way is using 'following' and adding the _ids creates an array by of all
  # the ids being followed by this user. Shorthand for 
  # user.following.map{ |i| i.id}
  # 
  # A smarter way is to use % ... % to create a SQL statement that will be 
  # run to get all the ids for the people followed, given a user id. This is 
  # more efficient, since the above method forces Rails to make the SQL statement
  # then give you back the objects, then transform into id ... much more tedious  # 
  # 
  # We include the user's own id as well through the OR inside the SQL statement
  def self.followed_by(user)
    # following_ids = user.following_ids
    
    following_ids = %(SELECT followed_id FROM relationships WHERE follower_id =
      :user_id)
    where("user_id IN (#{following_ids}) OR user_id = :user_id",
      { :user_id => user })
  end
  
end
