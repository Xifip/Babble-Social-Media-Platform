require 'spec_helper'

describe MessagesController do

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
      
    it "should deny access to 'show'" do
      get :show, :id => 1
      response.should redirect_to(signin_path)
      flash[:notice].should =~ /sign in/i
    end   
    
    it "should deny access to 'reply'" do
      get :reply, :id => 1
      response.should redirect_to(signin_path)
      flash[:notice].should =~ /sign in/i
    end    
    
    it "should deny access to 'forward'" do
      get :forward, :id => 1
      response.should redirect_to(signin_path)
      flash[:notice].should =~ /sign in/i
    end      
        
  end
  
  describe "for wrong users" do
    
    before(:each) do
      @user4 = test_sign_in(Factory(:user, :email => Factory.next(:email)))
      @receivedMessage = @user2.inbox.messages.first
    end
    
    it "should not be able to access someone else's mail" do
      get 'show', :id => @receivedMessage
      response.should_not be_success
    end
    
  end
  
  describe "GET 'show'" do
    
    before(:each) do
      test_sign_in(@user2)
      @receivedMessage = @user2.inbox.messages.first
    end
    
    it "should be successful" do
      get 'show', :id => @receivedMessage
      response.should be_success
    end
    
    it "should find the message" do
      get :show, :id => @receivedMessage
      assigns(:message).should == @receivedMessage
    end    
    
    it "should have the right author" do
      get :show, :id => @receivedMessage
      response.should have_selector("p", :content => @receivedMessage.author.name)
    end
    
    it "should have the right recipients" do
      get :show, :id => @receivedMessage
      response.should have_selector("p", :content => @receivedMessage.recipients.map(&:name).to_sentence)
    end
    
    it "should have the right create time" do
      get :show, :id => @receivedMessage
      response.should have_selector("p", :content => @receivedMessage.created_at.to_s(:long))
    end
    
    it "should have the right body" do
      get :show, :id => @receivedMessage
      response.should have_selector("div", :content => @receivedMessage.body)
    end
    
  end
  
  describe "GET 'reply'" do
    
    before(:each) do
      test_sign_in(@user2)
      @receivedMessage = @user2.inbox.messages.first
    end
    
    it "should be successful" do
      get :reply, :id => @receivedMessage
      response.should be_success
    end
    
    it "should have the right title" do
      get :reply, :id => @receivedMessage
      response.should have_selector("title", :content => @receivedMessage.subject.sub(/^(Re: )?/, "Re: "))
    end
    
    it "should have the right subject" do
      get :reply, :id => @receivedMessage
      response.should have_selector("input", :id => "message_subject", 
                  :value => @receivedMessage.subject.sub(/^(Re: )?/, "Re: "))
    end
    
    it "should have the right body" do
      get :reply, :id => @receivedMessage
      response.should have_selector("textarea", :id => "message_body", 
                  :content => @receivedMessage.body.gsub(/^/, "> "))
    end
    it "should have the right 'to' person selected" do
      # render_views is somehow not rendering checked="checked"...
      get :reply, :id => @receivedMessage
      response.should have_selector("div>input", :type => 'checkbox', :checked => 'checked', :id => @user.name.gsub(/\s+/, ""))
    end
    
  end
  
  describe "GET 'reply_all'" do
    
    before(:each) do
      test_sign_in(@user2)
      @receivedMessage = @user2.inbox.messages.first
    end
    
    it "should be successful" do
      get :reply_all, :id => @receivedMessage
      response.should be_success
    end
    
    it "should have the right title" do
      get :reply_all, :id => @receivedMessage
      response.should have_selector("title", :content => @receivedMessage.subject.sub(/^(Re: )?/, "Re: "))
    end
    
    it "should have the right subject" do
      get :reply_all, :id => @receivedMessage
      response.should have_selector("input", :id => "message_subject", 
                  :value => @receivedMessage.subject.sub(/^(Re: )?/, "Re: "))
    end
    
    it "should have the right body" do
      get :reply_all, :id => @receivedMessage
      response.should have_selector("textarea", :id => "message_body", 
                  :content => @receivedMessage.body.gsub(/^/, "> "))
    end
    it "should have the right 'to' person selected" do
      # render_views is somehow not rendering checked="checked"...
      get :reply_all, :id => @receivedMessage
      response.should have_selector("div>input", :type => 'checkbox', :checked => 'checked', :id => @user.name.gsub(/\s+/, ""))
      response.should have_selector("div>input", :type => 'checkbox', :checked => 'checked', :id => @user3.name.gsub(/\s+/, ""))
    end
    
  end
  
  describe "GET 'forward'" do
    
    before(:each) do
      test_sign_in(@user2)
      @receivedMessage = @user2.inbox.messages.first
    end
    
    it "should be successful" do
      get :forward, :id => @receivedMessage
      response.should be_success
    end
    
    it "should have the right title" do
      get :forward, :id => @receivedMessage
      response.should have_selector("title", :content => @receivedMessage.subject.sub(/^(Fw: )?/, "Fw: "))
    end
    
    it "should have the right subject" do
      get :forward, :id => @receivedMessage
      response.should have_selector("input", :id => "message_subject", 
                  :value => @receivedMessage.subject.sub(/^(Fw: )?/, "Fw: "))
    end
    
    it "should have the right body" do
      get :reply, :id => @receivedMessage
      response.should have_selector("textarea", :id => "message_body", 
                  :content => @receivedMessage.body.gsub(/^/, "> "))
    end
    
  end
  
  describe "PUT 'set_read_state'" do
    
    before(:each) do
      test_sign_in(@user2)
      @receivedMessage = @user2.inbox.messages.first
    end
    
    it "should be successful" do
      put :set_read_state, :id => @receivedMessage
      response.should redirect_to(inbox_path)
    end
    
    it "should change the unread state of the unread boolean" do
      @original_read_state = @receivedMessage.unread
      put :set_read_state, :id => @receivedMessage
      @receivedMessage.reload
      @receivedMessage.unread.should == !@original_read_state
    end
    
  end

end
