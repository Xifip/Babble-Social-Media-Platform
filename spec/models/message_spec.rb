require 'spec_helper'

describe Message do
  
  before(:each) do
    @user = Factory(:user)
    @user2 = Factory(:user, :email => Factory.next(:email))
    @user3 = Factory(:user, :email => Factory.next(:email))
    @attr = { :subject => "How are you?", :body => "How you're doing better than I
      am !", :to => [@user2, @user3]}
  end
  
  it "should create a new instance given valid attributes" do
    @user.sent_messages.create!(@attr)
  end
  
  describe "Message attributes" do

    before(:each) do
      @message = @user.sent_messages.create!(@attr)
    end

    it "should have an author attribute" do
      @message.should respond_to(:author)
    end

    it "should have a subject attribute" do
      @message.should respond_to(:subject)
    end

    it "should have a body attribute" do
      @message.should respond_to(:body)
    end

    it "should have a message_copies attribute" do
      @message.should respond_to(:message_copies)
    end

    it "should have a recipients attribute" do
      @message.should respond_to(:recipients)
    end

    it "should have the right author" do
      @message.author_id.should == @user.id
    end
  end
  
  describe "validations" do
    
    it "should not be able to create a message without a user" do
      Message.new(@attr).should_not be_valid
    end
    
    it "should not allow messages to be created without recipients" do
      @invalidM = @user.sent_messages.build(@attr.merge(:to => []))
      @invalidM.should_not be_valid
    end
    
    it "should not allow messages to be created without a subject" do
      @invalidM = @user.sent_messages.build(@attr.merge(:subject => ""))
      @invalidM.should_not be_valid
    end
    
    it "should not allow messages to be created without a body" do
      @invalidM = @user.sent_messages.build(@attr.merge(:body => " "))
      @invalidM.should_not be_valid
    end
    
  end
  
  describe "Message sending and receiving" do

    before(:each) do
      @user4 = Factory(:user, :email => Factory.next(:email))
      @message = @user.sent_messages.create!(@attr)
    end

    it "should have the right author" do
      @message.author_id.should == @user.id
    end
    
    it "should have the right recipients" do
      @message.recipients.should include(@user2)
      @message.recipients.should include(@user3)
      @message.recipients.should_not include(@user4)      
    end
    
    it "should have the right number of message_copies" do
      @message.message_copies.size.should == 2
    end
    
  end
  
end
