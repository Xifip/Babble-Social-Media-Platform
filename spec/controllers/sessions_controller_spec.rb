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
  
  describe "POST 'create_from_auth'" do
          
    
    it 'should allow sign up via OmniAuth' do
      lambda do
          
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter] 
        post :create_from_auth, :provider => 'twitter'
                 
      end.should change(User, :count).by(1)
        
    end 
    
    describe "sign in via OmniAuth" do
      
      before(:each) do
        # create a user via Twitter signup
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter] 
        post :create_from_auth, :provider => 'twitter'
        @user = User.find_by_provider_and_uid('twitter', '1234')
      end
      
      it "should sign in the user" do
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter] 
        post :create_from_auth, :provider => 'twitter'
        controller.current_user.should == @user
        controller.should be_signed_in
      end
      
      it "should redirect to the user to the user show page" do
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter] 
        post :create_from_auth, :provider => 'twitter'
        response.should redirect_to(root_path)
      end
      
      it "should be able to grab the proper details about the user from their auth object (declared in spec_helper)" do
        @user.name.should == 'user_nickname'
        @user.provider.should == 'twitter'
        @user.twitter_img_url.should == 'http://fakeimage.com'
        @user.twitter_username.should == 'user_nickname'
        @user.description.should == 'This is a mock user created for testing only'
        @user.auth_token.should == 'fakedToken'
        @user.auth_secret.should == 'easilyDiscoveredSecret'
      end
      
    end
        
  end

end
