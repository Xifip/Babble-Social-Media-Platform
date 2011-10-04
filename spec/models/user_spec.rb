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

require 'spec_helper'

describe User do
  
  before(:each) do
    @attr = {
      :name => "test name", 
      :email => "abc@gmail.com",
      :password => "password",
      :password_confirmation => "password"
    }
  end
  
  #the ! after create raises an invalid record error if the creation fails
  #the 'should' is a function provided through inheritance and accepts arguments
  
  it "should create a new instance given valid attibutes" do
    User.create!(@attr)    
  end
  
  it "should require a name" do
    nameless_user = User.new(@attr.merge(:name => ""))
    nameless_user.should_not be_valid
  end
  
  it "should require an email" do
    nameless_user = User.new(@attr.merge(:name => "has Name", :email => ""))
    nameless_user.should_not be_valid
  end
  
  it "should reject uber long names" do
    longName = "abc" * 51
    longNameUser = User.new(@attr.merge(:name => longName))
    longNameUser.should_not be_valid
  end
  
  it "should accept valid email addresses" do
    addresses = %w[uberman@gmail.com DA_PUMP@fuber.org first.last@blah.jp]
    addresses.each do |address|
      valid_email_user = User.new (@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end
  
  it "should reject invalid email addresses" do
    addresses = %w[blah@d,com user_.org faker.@donot.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end
  
  it "should reject users with the same email address" do
    User.create! (@attr)
    user2 = User.new (@attr)
    user2.should_not be_valid
  end
  
  it "should reject users with the same email address, irrespective of case" do
    User.create! (@attr)
    user2 = User.new (@attr.merge(:email => @attr[:email].upcase))
    user2.should_not be_valid
  end
  
  it "should be able to save a twitter user name" do
    User.create!(@attr.merge(:twitter_username => "lone_wolf989"))        
    found_user = User.find_by_name("test name")
    found_user.twitter_username.should == "lone_wolf989"
  end
  
  it "should not have a provider, being a normally signed up user" do
    User.create!(@attr.merge(:twitter_username => "lone_wolf989"))        
    found_user = User.find_by_name("test name")
    found_user.provider.should be_nil
    found_user.uid.should be_nil
  end
  
  describe "password validations" do
    
    it "should require a password" do
      user = User.new(@attr.merge(:password => "", :password_confirmation => ""))
      user.should_not be_valid
    end
    
    it "should require a matching password" do
      user = User.new(@attr.merge(:password => "", :password_confirmation => "asdf"))
      user.should_not be_valid
    end
    
    it "should reject short passwords" do
      shortpassword = "s" * 3
      hash = @attr.merge(:password => shortpassword, :password_confirmation => shortpassword)
      User.new(hash).should_not be_valid
    end
    
    it "should reject long passwords" do
      longpassword = "password" * 50
      hash = @attr.merge(:password => longpassword, :password_confirmation => longpassword)
      User.new(hash).should_not be_valid
    end
    
  end
  
  describe "password encryption" do
    
    before(:each) do
      @user = User.create!(@attr)      
    end
    
    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end
    
    it "should not have an empty encrypted password" do
      @user.encrypted_password.should_not be_blank
    end
    
    describe "has_password? method" do
      
      it "should be true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end
      
      it "should be false if the passwords don't match" do
        @user.has_password?("randomwords123").should be_false
      end
      
    end
    
    describe "authenticate method" do
      
      it "should return nil on email/password mismatch" do
        wrong_password_user = User.authenticate(@attr[:emai], "wrongpassword")
        wrong_password_user.should be_nil
      end
      
      it "should return nil for emails that dont match users" do
        wrong_email_user = User.authenticate("fakeemailthatdoesntexist@fake.com", @attr[:password])
        wrong_email_user.should be_nil
      end
      
      it "should return the user if the email and passwords match" do
        matching_user = User.authenticate(@attr[:email], @attr[:password])
        matching_user == @user
      end
      
    end
    
  end
  
  describe "admin attribute" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should respond to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be an admin by default" do
      @user.should_not be_admin
    end

    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
      
    end
    
  end
  
  describe "micropost associations" do
    
    before(:each) do
      @user = User.create!(@attr)
      @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
    end
    
    it "should respond to microposts" do
      @user.should respond_to(:microposts)
    end
    
    it "should return the micropost collection in reverse chronological order" do
      @user.microposts.should == [@mp2, @mp1]
    end
    
    it "should delete a user's microposts if the user is deleted" do
      @user.destroy
      [@mp1, @mp2].each do |mp|
        Micropost.find_by_id(mp.id).should be_nil
      end
    end
    
    describe "status feed" do
      
      it "should have a feed method" do
        @user.should respond_to(:feed)
      end
      
      it "should include the user's posts" do
        @user.feed.include?(@mp1).should be_true
        @user.feed.include?(@mp2).should be_true
      end
      
      it "should not contain another user's posts" do
        @user2 = Factory(:user, :email => Factory.next(:email))
        @mp3 = Factory(:micropost, :user => @user2)
        @user.feed.include?(@mp3).should be_false        
      end      
      
      it "should contain the posts of someone being followed" do
        @user3 = Factory(:user, :email => Factory.next(:email))
        @micropost_from_followed = Factory(:micropost, :user => @user3)
        @user.follow!(@user3)
        @user.feed.should include(@micropost_from_followed)
      end
      
    end
    
    
  end
    
  describe "relationships" do
      
    before(:each) do
      @user = User.create!(@attr)
      @followed = Factory(:user)
    end
      
    it "should have a relationships method" do
      @user.should respond_to(:relationships)
    end
      
    it "should have a following method" do
      @user.should respond_to(:following)
    end
      
    it "should have a following? method" do
      @user.should respond_to(:following?)
    end
      
    it "should have a follow! method" do
      @user.should respond_to(:follow!)
    end
      
    it "should follow another user" do
      @user.follow!(@followed)
      @user.should be_following(@followed)
    end
      
    it "should have the followed user inside the following array" do
      @user.follow!(@followed)
      @user.following.should include(@followed)
    end
      
    it "should have an unfollow! method" do
      @user.should respond_to(:unfollow!)
    end
      
    it "should unfollow a specific followed user" do
      @user.follow!(@followed)
      @user.unfollow!(@followed)
      @user.should_not be_following(@followed)
    end
      
    it "should have a reverse_relationships" do
      @user.should respond_to(:reverse_relationships)
    end
      
    it "should have a followers method" do
      @user.should respond_to(:followers)
    end
      
    it "should have users who follow a user" do
      @user.follow!(@followed)
      @followed.followers.should include(@user)
    end
    
    it "should destroy associated relationships when a user is deleted" do
      @user.follow!(@followed)
      @relationships = Relationship.find_all_by_follower_id(@user.id)
      @user.destroy
      @relationships.each do |rel|
        Relationship.find_by_id(rel.id).should be_nil
      end
      
    end
    
  end    
  
  describe "likes" do
    
    before(:each) do
      @user = User.create!(@attr)
      @user2 = Factory(:user)
      @attr = { :content => "value for content" }
      @micropost = @user2.microposts.create(@attr)
    end
    
    it "should have a likes method" do
      @user.should respond_to(:likes)
    end
    
    it "should have a posts_i_like method" do
      @user.should respond_to(:posts_i_like)
    end
    
    it "should have each posts_i_like as a micropost class" do
      @user.posts_i_like.each do |item|
        item.class.name.should == "Micropost"  
      end      
    end
    
    it "should have a liking? method" do
      @user.should respond_to(:liking?)
    end
    
    it "should have a like! method" do
      @user.should respond_to(:like!)
    end
    
    it "should like a post" do
      @user.like!(@micropost)
      @user.should be_liking(@micropost)
    end
    
    it "should include the liked post in the posts_i_like array" do
      @user.like!(@micropost)
      @user.posts_i_like.should include(@micropost)
    end
    
    it "should have an unlike! method" do
      @user.should respond_to(:unlike!)      
    end
    
    it "should unlike a post" do
      @user.like!(@micropost)
      @user.unlike!(@micropost)
      @user.should_not be_liking(@micropost)
    end
    
    it "should destroy associated likes when a user is deleted" do
      @user.like!(@micropost)
      @likes_by_user = Like.find_all_by_liker_id(@user.id)
      @user.destroy
      @likes_by_user.each do |like_instance|
        Like.find_by_id(like_instance.id).should be_nil
      end
      
    end
    
  end
  
  describe "messages" do
    
    before(:each) do
      @user = Factory(:user)
      @user2 = Factory(:user, :email => Factory.next(:email))
      @user3 = Factory(:user, :email => Factory.next(:email))
      @attr = { :subject => "How are you?", :body => "How you're doing better than I
      am !", :to => [@user2, @user3]}
      
      3.times do 
        @user.sent_messages.create!(@attr)
      end
      
    end
    
    it "should have unread_messages_count method" do
      @user2.should respond_to(:unread_messages_count)
    end
    
    it "should have the right unread_messages_count" do
      @user2.unread_messages_count.should == 3
    end
    
    it "should update the unread_messages_count according to the number of unread messages" do
      @message = @user2.inbox.messages.first
      @message.unread = false
      @message.save
      
      @user2.unread_messages_count.should == 2
    end
    
  end
  
  
end
