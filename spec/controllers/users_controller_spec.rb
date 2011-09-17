require 'spec_helper'

describe UsersController do

  render_views
  
  describe "GET 'show'" do
    
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    
    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end
    
    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end    
    
    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector("title", :content => @user.name)
    end
    
    it "should include the user's name" do
      get :show, :id => @user
      response.should have_selector("h1", :content => @user.name)
    end
    
    it "should have a profile picture" do
      get :show, :id => @user
      response.should have_selector("h1>img", :class => "gravatar")
    end
    
    it "should show the microposts collection for the user" do
      mp1 = Factory( :micropost, :user => @user, :content => "first post" )
      mp2 = Factory( :micropost, :user => @user, :content => "second post" )
      test_sign_in @user
      get :show, :id => @user
      response.should have_selector("li>div>div>h3", :content => mp1.content )
      response.should have_selector("li>div>div>h3", :content => mp2.content )      
    end
               
  end
  
  describe "GET 'new'" do
    
    it "should be successful" do
      get :new
      response.should be_success
    end
    
    it "should have the correct title" do
      get :new
      response.should be_success
      response.should have_selector("title", :content => "Sign Up")
    end
    
    it "should have a name field" do
      get :new
      response.should have_selector("input[name='user[name]'][type='text']")
    end
    
    it "should have an email field" do
      get :new
      response.should have_selector("input[name='user[email]'][type='text']")
    end
    
    it "should have a password field" do
      get :new
      response.should have_selector("input[name='user[password]'][type='password']")
    end
    
    it "should have a password_confirmation field" do
      get :new
      response.should have_selector("input[name='user[password_confirmation]'][type='password']")
    end
    
  end
  
  describe "POST 'create'" do
    
    describe "failure" do
      
      before(:each) do
        @attr = { :name => "", :email => "", :password => "", :password_confirmation => ""}        
      end
      
      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end
      
      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector("title", :content => 'Sign Up')
      end
      
      it "should render the new page" do
        post :create, :user => @attr
        response.should render_template('new')
      end
      
      it "should should have an error in the body of a JSON response" do
        post :create, :user => @attr, :format => :json
        body = JSON.parse(response.body)
        body["error"].should be_present
        body["error"].should =~ /sign up failed/i
      end
      
      it "not provide a cookie if the JSON request failed to create a user" do
        post :create, :user => @attr, :format => :json
        response.headers["Set-Cookie"].should_not be_present
      end
      
    end
    
    describe "success" do
      
      before(:each) do
        @attr = { :name => "Legit Tester", :email => "mr@legit.com", :password => "unguessable", :password_confirmation => "unguessable"}        
      end
      
      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end
      
      it "should redirect to the new user page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end
      
      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /welcome to babble/i
      end
      
      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end
      
      it "should create a user using JSON" do
        lambda do
          post :create, :user => @attr, :format => :json
        end.should change(User, :count).by(1)
      end
      
      it "should create a user and provided a cookie in response to successful JSON create" do
        post :create, :user => @attr, :format => :json
        response.should be_success
        response.headers["Set-Cookie"].should be_present
      end
      
    end
    
  end
  
  describe "GET 'Edit'" do
    
    before (:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    
    it "should be successful" do
      get :edit, :id => @user
      response.should be_successful
    end
    
    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector("title", :content => "Edit")
    end
    
    it "should have a link to change the avatar" do
      get :edit, :id => @user
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href => gravatar_url, :content => "change")
    end
    
  end
  
  describe "PUT 'update'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    describe "failure" do

      before(:each) do
        @attr = { :email => "", :name => "", :password => "",
          :password_confirmation => "" }
      end

      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end

      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector("title", :content => "Edit")
      end
    end 
    
    describe "success" do

      before(:each) do
        @attr = { :name => "New Name", :email => "user@example.org",
          :password => "barbaz", :password_confirmation => "barbaz" }
      end

      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should  == @attr[:name]
        @user.email.should == @attr[:email]
      end

      it "should redirect to the user show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end

      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end
    end
  end
  
  describe "authentication of edit/update pages" do

    before(:each) do
      @user = Factory(:user)
    end

    describe "for non-signed-in users" do

      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end
      
      # make sure that signed in users can't edit or update profiles for other
      # users
      
      describe "for signed-in users" do

        before(:each) do
          wrong_user = Factory(:user, :email => "user_the_wrong_user@wrong.net")
          test_sign_in(wrong_user)
        end

        it "should only be able 'edit' their own profile" do
          get :edit, :id => @user
          response.should redirect_to(root_path)
        end

        it "should only be able to 'update' their own profile" do
          put :update, :id => @user, :user => {}
          response.should redirect_to(root_path)
        end
      end
    end
  end
  
  describe "Get 'index'" do
    
    describe "for non-signed visitors" do
      
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end      
    end
    
    describe "for signed-in users" do
      
      before(:each) do
        @user = test_sign_in(Factory(:user))
        second = Factory(:user, :name => "Mai", :email => "mai@gmail.com")
        third  = Factory(:user, :name => "Ken", :email => "kentaro@docobo.net")
        
        @users = [@user, second, third]
        
        30.times do
          @users << Factory(:user, :email => Factory.next(:email))
        end
        
      end
      
      it "should be successful" do
        get :index
        response.should be_success
      end
      
      
      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "Users")
      end
      
      it "should have an element for each user" do
        get :index
        @users[0..2].each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end
      
      it "should paginate users" do
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a", :href => "/users?page=2",
          :content => "2")
        response.should have_selector("a", :href => "/users?page=2",
          :content => "Next")
      end
      
      it "should not have delete links beside users for non-admin users" do
        get :index
        response.should_not have_selector("a", :content => "delete")
      end
      
      it "should have delete links beside users for admin users" do
        test_sign_in(Factory(:user, :email => "admin@email.com", :admin => true))
        get :index
        response.should have_selector("a", :content => "delete")        
      end
      
    end   
       
  end
  
  describe "DELETE 'destroy'" do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    describe "as a non-signed in user" do
      
      it "should deny access and go to sign in path" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
      
    end
    
    describe "as a non-admin user" do
      
      it "should prevent you from deleting the user" do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
      
    end
    
    describe "as an admin user" do
      
      before(:each) do
        @admin = Factory(:user, :email => "admin@email.com", :admin => true)
        test_sign_in(@admin)
      end
      
      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end

      it "should redirect to the users page if user is already deleted" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end
      
      it "should not allow admins to delete themselves" do
        lambda do
          delete :destroy, :id => @admin
          flash[:error].should =~ /cannot/i
          response.should redirect_to(users_path)  
        end.should_not change(User, :count)
      end
      
    end    
  end
  
  describe "following and follower pages" do
    
    describe "when not signed in" do
      
      before(:each) do
        Factory(:user)
      end
      
      it "should protect 'following" do
        get :following, :id => 1
        response.should redirect_to(signin_path)
      end
      
      it "should protect 'followers" do
        get :followers, :id => 1
        response.should redirect_to(signin_path)
      end      
    end
    
    describe "when signed in" do
      
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @other_user = Factory(:user, :email => Factory.next(:email))
        @user.follow!(@other_user)
      end
      
      it "should have show the user's following" do
        get :following, :id => @user
        response.should have_selector("a", :href => user_path(@other_user), :content => @other_user.name)
      end
      
      it "should show user under other_user's following" do
        get :followers, :id => @other_user
        response.should have_selector("a", :href => user_path(@user), :content => @user.name)
      end
      
      it "should show the follwed user's posts, but not have a delete link for them" do
        mp = Factory( :micropost, :user => @other_user, :content => "someone else's
        post")
        get :show, :id => @user
        response.should_not have_selector("li>div>a", :content => "delete" ) 
      end
    end
      
  end
    
end

