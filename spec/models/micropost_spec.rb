require 'spec_helper'

describe Micropost do
  
  before(:each) do
    @user = Factory(:user)
    @attr = { :content => "value for content" }
  end

  it "should create a new instance given valid attributes" do
    @user.microposts.create!(@attr)
  end

  describe "user associations" do

    before(:each) do
      @micropost = @user.microposts.create(@attr)
    end

    it "should have a user attribute" do
      @micropost.should respond_to(:user)
    end

    it "should have the right associated user" do
      @micropost.user_id.should == @user.id
      @micropost.user.should == @user
    end
  end
  
  describe "validations on" do
    
    it "should be unable to create a micropost by itself without a user" do
      Micropost.new(@attr).should_not be_valid
    end
    
    it "should reject empty / blank content" do
      @micropost = @user.microposts.build(:content => " ")
      @micropost.should_not be_valid            
    end
    
    it "should reject long content" do
      @micropost = @user.microposts.build(:content => "a" * 201 )
      @micropost.should_not be_valid      
    end
  end
  
  describe "from_users_followed_by" do
    
    before(:each) do
      @other_user = Factory(:user, :email => Factory.next(:email))
      @third_user = Factory(:user, :email => Factory.next(:email))

      @user_post  = @user.microposts.create!(:content => "main user post")
      @other_post = @other_user.microposts.create!(:content => "other user post")
      @third_post = @third_user.microposts.create!(:content => "third user post")

      @user.follow!(@other_user)
    end
    
    it "should respond to a call to the from_users_followed_by method" do
      Micropost.should respond_to(:from_users_followed_by)
    end
    
    it "should contain the posts by oneself" do
      Micropost.from_users_followed_by(@user).should include(@user_post)
    end
    
    it "should contain the posts by a followed user" do
      Micropost.from_users_followed_by(@user).should include(@other_post)
    end
    
    it "should not contain the posts of someone not being followed" do
      Micropost.from_users_followed_by(@user).should_not include(@third_post)
    end
  end
  
  describe "likes" do
    
    before(:each) do
      @micropost = @user.microposts.create(@attr)
      @user2 = Factory(:user, :email => Factory.next(:email))
      @user3 = Factory(:user, :email => Factory.next(:email))
    end
    
    it "should respond to a call to likes method" do
      @micropost.should respond_to(:likes)
    end
    
    it "should respond to a call to the likers method" do
      @micropost.should respond_to(:likers)
    end
    
    it "should respond to a call to a likes_count method" do
      @micropost.should respond_to(:likes_count)
    end
    
    it "should have the right number of likes" do
      @user2.like!(@micropost)
      @micropost.likes_count.should == 1
      @user3.like!(@micropost)
      @micropost.likes_count.should == 2
      @user2.unlike!(@micropost)
      @micropost.likes_count.should == 1
    end    
    
  end
  
end
