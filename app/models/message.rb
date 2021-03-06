class Message < ActiveRecord::Base
  belongs_to :author, :class_name => "User"
  has_many :message_copies
  has_many :recipients, :through => :message_copies
  
  #before actually creating, run :prepare_copies
  before_create :prepare_copies
  
  attr_accessor  :to # array of people to send to
  attr_accessible :subject, :body, :to
  
  validates :subject, :presence => true
  validates :body, :presence => true  
  validates :author, :presence => true
  validates :to, :presence => true
   
  
  private
  
  def prepare_copies
    return if to.blank?
    
    to.each do |recipient|
      recipient = User.find(recipient)
      message_copies.build(:recipient_id => recipient.id, :folder_id => recipient.inbox.id)
    end
  end
  
end
