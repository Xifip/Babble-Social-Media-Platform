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
      @user = test_sign_in(Factory(:user))
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
      @user = test_sign_in(Factory(:user))
      @micropost = Factory( :micropost, :user => @user, :content => "post" )   
      @user.like!(@micropost)
      @like = @user.likes.find_by_liked_id(@micropost)
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
  
  
  
end

