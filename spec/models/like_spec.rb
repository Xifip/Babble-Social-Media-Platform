require 'spec_helper'

describe Like do
  
  before(:each) do
    @user = Factory(:user)
    @user2 = Factory(:user, :email => Factory.next(:email))    
    @micropost = @user2.microposts.create( :content => "something inside a post")
    
    @like = @user.likes.build( :liked_id => @micropost.id )
    
  end
  
  it "should create a new like" do
    @like.save!
  end
  
  it "should have a liker attribute" do
    @like.should respond_to(:liker)
  end
  
  it "should have the right liker" do
    @like.liker.should == @user
  end
  
  it "should have a liked attribute" do
    @like.should respond_to(:liked)
  end
  
  it "should have the right liked" do
    @like.liked.should == @micropost
  end
  
  describe "validations" do
    
    it "should require a liker_id" do
      @like.liker_id = nil
      @like.should_not be_valid
    end
    
    it "should require a liked_id" do
      @like.liked_id = nil
      @like.should_not be_valid
    end
  end
  
end
