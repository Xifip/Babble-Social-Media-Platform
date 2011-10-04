require 'spec_helper'

describe SentController do
  
  render_views

  before(:each) do
    @user = Factory(:user)
    @user2 = Factory(:user, :email => Factory.next(:email))
    @user3 = Factory(:user, :email => Factory.next(:email))
    @message_attr = { :subject => "How are you?", :body => "How you're doing better than I
      am !", :to => [@user2, @user3]}    
  end
  
  
  describe "for non-signed visitors" do
      
    it "should deny access to 'index'" do
      get :index
      response.should redirect_to(signin_path)
      flash[:notice].should =~ /sign in/i
    end      
    
    it "should deny access to 'show'" do
      get :show, :id => 1
      response.should redirect_to(signin_path)
      flash[:notice].should =~ /sign in/i
    end      
    
    it "should deny access to 'new'" do
      get :new
      response.should redirect_to(signin_path)
      flash[:notice].should =~ /sign in/i
    end      
    
    it "should deny access to 'create'" do
      get :create
      response.should redirect_to(signin_path)
      flash[:notice].should =~ /sign in/i
    end      
    
  end
  
  describe "for wrong users" do
    
    before(:each) do
      @user1_message = @user.sent_messages.create(@message_attr)      
      @anoter_user = test_sign_in(Factory(:user, :email => Factory.next(:email)))      
    end
    
    it "should not be able to see someone else's sent messages" do
      get 'show', :id => @user1_message
      response.should_not be_success
    end
    
  end
  
  describe "GET 'show'" do
    
    before(:each) do
      test_sign_in(@user)
      @message = @user.sent_messages.create(@message_attr)
    end
    
    it "should be successful" do
      get 'show', :id => @message
      response.should be_success
    end
    
    it "should find the message" do
      get :show, :id => @message
      assigns(:message).should == @message
    end    
    
    it "should have the right title" do
      get :show, :id => @message
      response.should have_selector("title", :content => @message.subject)
    end
    
    it "should have the message body" do
      get :show, :id => @message
      response.should have_selector("div", :content => @message.body)
    end
    
    it "should show the message recipients" do
      get :show, :id => @message
      response.should have_selector("p", :content => @message.recipients.map(&:name).to_sentence)
    end
    
    it "should show the sent time of the message" do
      get :show, :id => @message
      response.should have_selector("p", :content => @message.created_at.to_s(:long))
    end
        
  end
  
  describe "GET 'index'" do
    
    before(:each) do
      test_sign_in(@user)
      
      30.times do
        @user.sent_messages.create!(@message_attr)        
      end
      
    end
    
    it "should be successful" do
      get 'index'
      response.should be_success
    end           
      
    it "should have the right title" do
      get :index
      response.should have_selector("title", :content => "Sent Messages")
    end
      
    it "should have an element for each message" do
      get :index
      @user.sent_messages.each do |message|
        response.should have_selector("td", :content => message.recipients.map(&:name).to_sentence)
      end
    end
      
    it "should paginate messages" do
      get :index
      response.should have_selector("div.pagination")
      response.should have_selector("span.disabled", :content => "Previous")
      response.should have_selector("a", :href => "/sent?page=2",
        :content => "2")
      response.should have_selector("a", :href => "/sent?page=2",
        :content => "Next")
    end
          
  end


  describe "GET 'new'" do
    
    before(:each) do
      test_sign_in(@user)
    end
    
    it "should be successful" do
      get 'new'
      response.should be_success
    end
    
    it "should have the correct title" do
      get :new
      response.should be_success
      response.should have_selector("title", :content => "New Message")
    end
    
    it "should have a title field" do
      get :new
      response.should have_selector("input[name='message[subject]'][type='text']")
    end
    
    it "should have an body field" do
      get :new
      response.should have_selector("textarea[name='message[body]']")
    end
    
  end
  
  describe "POST 'create'" do
    
    before(:each) do
      test_sign_in(@user)
    end
    
    
    describe "failure" do
      
      before(:each) do
        @invalid_attr = { :subject => "", :body => "", :to => []}        
      end
      
      it "should not create a user" do
        lambda do
          post :create, :message => @invalid_attr
        end.should_not change(Message, :count)
      end
      
      it "should have the right title" do
        post :create, :message => @invalid_attr
        response.should have_selector("title", :content => 'New Message')
      end
      
      it "should render the new page" do
        post :create, :message => @invalid_attr
        response.should render_template('new')
      end
      
    end
    
    describe "success" do
            
      it "should create a message" do
        lambda do
          post :create, :message => @message_attr
        end.should change(Message, :count).by(1)
      end
      
      it "should redirect to the Sent Messages index" do
        post :create, :message => @message_attr
        response.should redirect_to(:action => "index")
      end
      
    end
    
  end

  
end
