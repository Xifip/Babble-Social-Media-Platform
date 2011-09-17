require 'spec_helper'

describe LikesController do
  
  describe "access control" do
    
    it "should require sign in for likes creation" do
      post :create
      response.should redirect_to(signin_path)
    end
    
    it "should require sign in for likes deletion" do
      post :destroy, :id => 1
      response.should redirect_to(signin_path)
    end
    
  end
  
  describe "POST 'create'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(Factory(:user, :email => Factory.next(:email)))
      @micropost = Factory( :micropost, :user => @user, :content => "post" )      
    end
    
    it "should create a like" do
      lambda do
        post :create, :like => { :liked_id => @micropost }
        response.should be_redirect
      end.should change(Like, :count).by(1)
    end
    
    it "should create a like using AJAX" do
      lambda do
        xhr :post, :create, :like => { :liked_id => @micropost }
        response.should be_success
      end.should change(Like, :count).by(1)
    end
        
  end

  describe "DELETE 'destroy'" do

    before(:each) do
      @user = Factory(:user)
      @user2 = test_sign_in(Factory(:user, :email => Factory.next(:email)))
      @micropost = Factory( :micropost, :user => @user, :content => "post" )   
      @user2.like!(@micropost) 
      @like = @user2.likes.find_by_liked_id(@micropost)
    end

    it "should destroy a like" do
      lambda do
        delete :destroy, :id => @like
        response.should be_redirect
      end.should change(Like, :count).by(-1)
    end
    
    it "should destroy a like using AJAX" do
      lambda do
        xhr :delete, :destroy, :id => @like
        response.should be_success
      end.should change(Like, :count).by(-1)
    end
        
  end
  
  describe "invalid liking and unliking" do
    
    before(:each) do
      @user = Factory(:user)
      @user2 = Factory(:user, :email => Factory.next(:email))
      @user3 = Factory(:user, :email => Factory.next(:email))
      @micropost = Factory( :micropost, :user => @user, :content => "post" )         
    end
    
    it "should not allow a user to like their own posts" do
      lambda do
        test_sign_in(@user)
        post :create, :like => { :liked_id => @micropost }
      end.should_not change(Like, :count)      
    end
    
    it "should not allow a user to unlike their own posts" do
      @user2.like!(@micropost)
      @like = @user2.likes.find_by_liked_id(@micropost)
      test_sign_in(@user)
      lambda do
        delete :destroy, :id => @like
        response.should be_redirect
      end.should_not change(Like, :count)
    end
    
    it "should not allow a user to delete someone else's like" do
      
      @user2.like!(@micropost)
      @like = @user2.likes.find_by_liked_id(@micropost)
      test_sign_in(@user3)
      lambda do
        delete :destroy, :id => @like
        response.should be_redirect
      end.should_not change(Like, :count)
    end
  end
end

