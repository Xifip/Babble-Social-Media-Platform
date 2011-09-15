require 'spec_helper'

describe SessionsController do
  
  render_views

  describe "GET 'new'" do
    
    it "should be successful" do
      get :new
      response.should be_success
    end
    
    it "should have the right title" do
      get :new
      response.should have_selector("title", :content => "Sign in")
    end
    
  end
  
  describe "POST 'create'" do
    
    describe "invalid sign in" do
    
      before(:each) do
        @attr = { :email => "email@example.com", :password => "randomInvalidPassword"}
      end
    
      it "should render a new page" do
        post :create, :session => @attr
        response.should render_template('new')
      end
    
      it "should have the right title" do
        post :create, :session => @attr
        response.should have_selector("title", :content => "Sign in")
      end
    
      it "should have a flash.now message" do
        post :create, :session => @attr
        flash.now[:error].should =~ /invalid/i
      end
      
      it "should should have an error in the body of a JSON response" do
        post :create, :session => @attr, :format => :json
        body = JSON.parse(response.body)
        body["error"].should be_present
        body["error"].should =~ /invalid user or email/i
      end
      
      it "should not provide a cookie if the JSON request failed to create a session" do
        post :create, :session => @attr, :format => :json
        response.headers["Set-Cookie"].should_not be_present
      end
      
    end   
    
    describe "valid sign in" do
      
      before(:each) do
        @user = Factory(:user)
        @attr = { :email => @user.email, :password => @user.password }
      end
      
      it "should sign the user in" do
        post :create, :session => @attr
        controller.current_user.should == @user
        controller.should be_signed_in
      end
      
      it "should redirect to the user to the user show page" do
        post :create, :session => @attr
        response.should redirect_to(root_path)
      end
      
      it "should sign a user in using JSON by providing a cookie" do
        post :create, :session => @attr, :format => :json
        response.should be_success
        response.headers["Set-Cookie"].should be_present
      end
      
    end
    
  end
  
  describe "DELETE 'destroy'" do
    
    it "should sign a user out" do
      test_sign_in(Factory(:user))
      delete :destroy
      controller.should_not be_signed_in
      response.should redirect_to(root_path)
    end
    
  end

end
