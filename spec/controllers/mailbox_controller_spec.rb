require 'spec_helper'

describe MailboxController do

  render_views

  before(:each) do
    @user = Factory(:user)
    @user2 = Factory(:user, :email => Factory.next(:email))
    @user3 = Factory(:user, :email => Factory.next(:email))
    @message_attr = { :subject => "How are you?", :body => "How you're doing better than I
      am !", :to => [@user2, @user3]}    
    
    30.times do
      @user.sent_messages.create!(@message_attr)
    end
  end
  
  
  describe "for non-signed visitors" do
      
    it "should deny access to 'index'" do
      get :index
      response.should redirect_to(signin_path)
      flash[:notice].should =~ /sign in/i
    end      
    
    it "should deny access to 'show'" do
      get :show
      response.should redirect_to(signin_path)
      flash[:notice].should =~ /sign in/i
    end      
        
  end
  
  describe "for wrong users" do
    
    before(:each) do
      @user4 = test_sign_in(Factory(:user, :email => Factory.next(:email)))
      @inbox_for_user2 = @user2.inbox
    end
    
    it "should not be able to access someone else's mail" do
      get 'show', :id => @inbox_for_user2
      response.should_not be_success
    end
    
  end
   
  describe "GET 'show'" do
    
    before(:each) do
      test_sign_in(@user)
      @newFolder = @user.folders.create!(:name => "Just a folder")
    end
    
    it "should be successful" do
      get 'show', :id => @newFolder
      response.should be_success
    end
    
    it "should find the folder" do
      get :show, :id => @newFolder
      assigns(:folder).should == @newFolder
    end    
    
    it "should have the right name" do
      get :show, :id => @newFolder
      response.should have_selector("title", :content => @newFolder.name)
    end
  end
  
  describe "GET 'index'" do
    
    before(:each) do
      test_sign_in(@user2)      
    end
    
    it "should be successful" do
      get :index
      response.should be_success
    end
    
    it "the folder should be the Inbox" do
      get :index
      response.should have_selector("title", :content => "Inbox")
    end
    
    it "getting show without should have an element for each message" do
      get :index
      @user2.sent_messages.each do |message|
        response.should have_selector("td", :content => message.recipients.map(&:name).to_sentence)
      end
    end
      
    it "should paginate messages" do
      get :index
      response.should have_selector("div.pagination")
      response.should have_selector("span.disabled", :content => "Previous")
      response.should have_selector("a", :href => "/mailbox?page=2",
        :content => "2")
      response.should have_selector("a", :href => "/mailbox?page=2",
        :content => "Next")
    end
        
  end
  

end
