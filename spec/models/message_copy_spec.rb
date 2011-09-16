require 'spec_helper'

describe MessageCopy do
    
  before(:each) do
    @user = Factory(:user)
    @user2 = Factory(:user, :email => Factory.next(:email))
    @user3 = Factory(:user, :email => Factory.next(:email))
    @attr = { :subject => "How are you?", :body => "How you're doing better than I
      am !", :to => [@user2, @user3]}
    @message = @user.sent_messages.create!(@attr)
    
  end
  
  describe "Message_copy attributes" do
    
    before(:each) do
      @message = @user.sent_messages.create!(@attr)
      @messageCopy1 = @user2.inbox.messages.find_by_message_id(@message)      
    end
    
    it "should have an author attribute" do
      @messageCopy1.should respond_to(:author)
    end

    it "should have a subject attribute" do
      @messageCopy1.should respond_to(:subject)
    end

    it "should have a body attribute" do
      @messageCopy1.should respond_to(:body)
    end

    it "should have a recipient attribute" do
      @messageCopy1.should respond_to(:recipient)
    end

    it "should have a folder attribute" do
      @messageCopy1.should respond_to(:folder)
    end
    
    it "should have a folder attribute" do
      @messageCopy1.should respond_to(:message)
    end
    
    it "should have a recipients attribute" do
      @messageCopy1.should respond_to(:recipients)
    end

    it "should have the right author" do
      @messageCopy1.author.should == @user
    end
    
  end
  
  describe "Message_copy fields" do
    
    before(:each) do
      @messageCopies = 
        [ @user2.inbox.messages.find_by_message_id(@message),
      @messageCopy2 = @user3.inbox.messages.find_by_message_id(@message)]
    end
    
    it "should have the right author" do
      @messageCopies.each do |messageCopy|
        messageCopy.author.should == @user
      end
    end
    
    it "should have the right subject" do
      @messageCopies.each do |messageCopy|
        messageCopy.subject.should == @attr[:subject]
      end
    end
    
    it "should have the right body" do
      @messageCopies.each do |messageCopy|
        messageCopy.body.should == @attr[:body]
      end
    end
    
    it "should have the right recipient" do
      @messageCopies.each do |messageCopy|
        messageCopy.recipient.should == messageCopy.folder.user
      end
    end
    
    it "should have the right recipients" do
      @messageCopies.each do |messageCopy|
        messageCopy.recipients.should == @attr[:to]
      end
    end
    
    it "should have the right message" do
      @messageCopies.each do |messageCopy|
        messageCopy.message.should == @message
      end
    end
    
  end
  
end
