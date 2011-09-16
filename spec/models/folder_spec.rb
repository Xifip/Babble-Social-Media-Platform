require 'spec_helper'

describe Folder do
  
  before(:each) do
    @user = Factory(:user)
    @attr = { :name => "Just a Message Folder" }
  end
  
  describe "folder associations" do
    
    before(:each) do
      @folder = @user.folders.build(@attr)
    end
    
    it "should have a user attribute" do
      @folder.should respond_to(:user)
    end
    
    it "should have a parent attribute" do
      @folder.should respond_to(:parent)
    end
    
    it "should have a name attribute" do
      @folder.should respond_to(:name)
    end
    
  end
  
  describe "user should have an Inbox folder upon creation" do
    
    it "should have a default Inbox folder" do
      @user.inbox.name.should eql("Inbox")      
    end
    
    it "should create and save a folder" do
      @newFolder = @user.folders.build(@attr)
      @newFolder.should be_valid
      @newFolder.save!
      @user.folders.find_by_name("Just a Message Folder").should == @newFolder
    end
    
  end
  
  describe "validations" do
    
    it "should enforce a name" do
      @newFolder = @user.folders.build(:name => "")
      @newFolder.should_not be_valid
    end
    
    it "should not create a newFolder by itself" do
      @newFolder = @user.folders.build(@attr)
      @newFolder.user = nil
      @newFolder.should_not be_valid   
    end
    
  end
  
  describe "folder nesting" do
    
    before(:each) do
      @subFolder = @user.folders.create!(@attr.merge(:parent => @user.inbox))
    end
    
    it "should have the right parent folder" do
      @subFolder.parent.should == @user.inbox
    end
    
  end
  
end
