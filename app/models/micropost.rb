class Micropost < ActiveRecord::Base
  
  attr_accessor :tweet_now
  
  attr_accessible :content, :photo, :photo_file_name, :photo_content_type, 
    :photo_file_size, :photo_updated_at, :tweet_now
     
  belongs_to :user
  
  #likes
  has_many :likes, :foreign_key => "liked_id", :dependent => :destroy
  has_many :likers, :through => :likes, :source => :liker, 
    :class_name => "User"
  
  has_attached_file :photo, 
    # override original size to save space in order to allow any size uploads  
  :styles => { :large => "900", :original => "600", :small => "300"},
    :storage => :s3,
    :s3_credentials => Rails.root.join("config","s3.yml").to_s,    
    :path => ":attachment/:id/:style/:filename",
    :bucket => 'babblephotos'
  
  default_scope :order => 'microposts.created_at DESC'
  
  scope :from_users_followed_by, lambda { |user| followed_by(user)}
  
  #validations
  
  validates :user, :presence => true
  validates :content, :presence => true, :length => { :maximum => 200}
  validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png'], :if => :photo_attached?
    
  def likes_count 
    likes.count
  end
  
  def preview_content
    if content.length < 24
      return content
    else
      return content[0..20] << " ..."
    end
  end
    
  def self.random_where(*params)
    if (c = where(*params).count) != 0
      where(*params).find(:first, :offset =>rand(c))
    end
  end
  
  def self.recent_most_popular
    
    recent_most_popular_posts = find( 
      :all,
      # :conditions => ["microposts.created_at > ?", 2.weeks.ago], <--to be uncommented when site gets more popular
      :joins => :likes,
      :group => ' microposts.content, 
                  microposts.id, 
                  microposts.user_id, 
                  microposts.created_at,
                  microposts.updated_at,
                  microposts.photo_file_name',
      :order => 'COUNT(likes.liked_id) DESC, created_at',                                
      :limit => 5)
    return recent_most_popular_posts
    
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
  
  def photo_attached?
    self.photo.file?
  end
  
end
