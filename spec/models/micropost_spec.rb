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
  
end
