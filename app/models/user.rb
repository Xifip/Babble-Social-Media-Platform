# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class User < ActiveRecord::Base
    
  #---Accessors---
  #Setting accessible attributes
  #attributes that are 'virtual'; they can only exist in memory
  attr_accessor :password
  
  #normally persisted attribute accessors, only attributes in this list can be
  #set via normal http requests
  attr_accessible :name, :email, :password, :password_confirmation
  
  #---Relationships---
  
  #microposts
  has_many :microposts, :dependent => :destroy
  
  #users followed by this user, aka, people this user is following
  has_many :relationships, :foreign_key => "follower_id", :dependent => :destroy
  has_many :following, :through => :relationships, :source => :followed
  
  #users that are following this user, aka followers of this user, need to declare
  #class_name because Rails can't figure out what to do with 'reverse'
  has_many :reverse_relationships, :foreign_key => "followed_id", :class_name =>
    "Relationship", :dependent => :destroy
  has_many :followers, :through => :reverse_relationships, :source => :follower
  
  #likes
  has_many :likes, :foreign_key => "liker_id", :dependent => :destroy
  has_many :posts_i_like, :through => :likes, :source => :liked, 
    :class_name => "Micropost"
  
  #messages
  has_many :sent_messages, :class_name => "Message", :foreign_key => "author_id"
  has_many :received_messages, :class_name => "MessageCopy", :foreign_key => "recipient_id"
  has_many :folders
  
  #---Validations---
  
  #email regular expression to make sure emails are of valid format
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :name, :presence => true, :length => { :maximum => 50}
  validates :email, :presence => true, :format => { :with => email_regex }, :uniqueness => { :case_sensitive => false }
  
  # Validation for the virtual password; password_confirmation validation is automatically created
  validates :password, :presence => true, :confirmation => true, :length => { :within => 6..40 }
  
  before_create :build_inbox
  
  before_save :encrypt_password
    
  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil if user.nil?
    return user if user.has_password?(submitted_password)
  end
  
  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end
  
  def has_password?(submitted_password)
    #compare encrypted passwords with the submitted_password
    encrypted_password == encrypt(submitted_password)
  end
  
  def feed
    Micropost.from_users_followed_by(self)
  end
  
  def following?(followed)
    relationships.find_by_followed_id(followed)    
  end
  
  def follow!(followed)
    relationships.create!(:followed_id => followed.id)
  end
  
  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy
  end
  
  def liking?(liked)
    likes.find_by_liked_id(liked)
  end
  
  def like!(liked)
    likes.create!(:liked_id => liked.id)
  end
  
  def unlike!(liked)
    likes.find_by_liked_id(liked).destroy
  end
  
  def inbox
    @inboxFolder = folders.find_by_name("Inbox")
    @inboxFolder ||= folders.build(:name => "Inbox")    
  end  
  
  def self.create_with_omniauth(auth)
    
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["user_info"]["nickname"]
      user.email = auth["user_info"]["name"].gsub(/\s+/, "") << "@fromTwitter.com"
      user.twitter_img_url = auth["user_info"]["image"]
      user.password = auth["uid"][0..40]
      
    end
  end

  
  private
  
  def encrypt_password
    self.salt = make_salt if new_record?
    self.encrypted_password = encrypt(password)
  end
    
  def make_salt
    secure_hash("#{Time.now.utc}--#{password}")
  end
    
  def secure_hash(string)
    Digest::SHA2.hexdigest(string)
  end
        
  def encrypt(string)
    secure_hash("#{salt}--#{string}")
  end
    
  def build_inbox
    folders.build(:name => "Inbox")
  end
end
