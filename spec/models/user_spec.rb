# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe User do
  
  before(:each) do
    @attr = {
      :name => "test name", 
      :email => "abc@gmail.com",
      :password => "password",
      :password_confirmation => "password"
      }
  end
  
  #the ! after create raises an invalid record error if the creation fails
  #the 'should' is a function provided through inheritance and accepts arguments
  
  it "should create a new instance given valid attibutes" do
    User.create!(@attr)    
  end
  
  it "should require a name" do
    nameless_user = User.new(@attr.merge(:name => ""))
    nameless_user.should_not be_valid
  end
  
  it "should require an email" do
    nameless_user = User.new(@attr.merge(:name => "has Name", :email => ""))
    nameless_user.should_not be_valid
  end
  
  it "should reject uber long names" do
    longName = "abc" * 51
    longNameUser = User.new(@attr.merge(:name => longName))
    longNameUser.should_not be_valid
  end
  
  it "should accept valid email addresses" do
    addresses = %w[uberman@gmail.com DA_PUMP@fuber.org first.last@blah.jp]
    addresses.each do |address|
      valid_email_user = User.new (@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end
  
  it "should reject invalid email addresses" do
    addresses = %w[blah@d,com user_.org faker.@donot.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end
  
  it "should reject users with the same email address" do
    User.create! (@attr)
    user2 = User.new (@attr)
    user2.should_not be_valid
  end
  
  it "should reject users with the same email address, irrespective of case" do
    User.create! (@attr)
    user2 = User.new (@attr.merge(:email => @attr[:email].upcase))
    user2.should_not be_valid
  end
  
  describe "password validations" do
    
    it "should require a password" do
      user = User.new(@attr.merge(:password => "", :password_confirmation => ""))
      user.should_not be_valid
    end
    
    it "should require a matching password" do
      user = User.new(@attr.merge(:password => "", :password_confirmation => "asdf"))
      user.should_not be_valid
    end
    
    it "should reject short passwords" do
      shortpassword = "s" * 3
      hash = @attr.merge(:password => shortpassword, :password_confirmation => shortpassword)
      User.new(hash).should_not be_valid
    end
    
    it "should reject long passwords" do
      longpassword = "password" * 50
      hash = @attr.merge(:password => longpassword, :password_confirmation => longpassword)
      User.new(hash).should_not be_valid
    end
    
  end
  
  describe "password encryption" do
    
    before(:each) do
      @user = User.create!(@attr)      
    end
    
    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end
    
    it "should not have an empty encrypted password" do
      @user.encrypted_password.should_not be_blank
    end
    
    describe "has_password? method" do
      
      it "should be true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end
      
      it "should be false if the passwords don't match" do
        @user.has_password?("randomwords123").should be_false
      end
      
    end
    
    describe "authenticate method" do
      
      it "should return nil on email/password mismatch" do
        wrong_password_user = User.authenticate(@attr[:emai], "wrongpassword")
        wrong_password_user.should be_nil
      end
      
      it "should return nil for emails that dont match users" do
        wrong_email_user = User.authenticate("fakeemailthatdoesntexist@fake.com", @attr[:password])
        wrong_email_user.should be_nil
      end
      
      it "should return the user if the email and passwords match" do
        matching_user = User.authenticate(@attr[:email], @attr[:password])
        matching_user == @user
      end
      
    end
    
  end
  
  describe "admin attribute" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should respond to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be an admin by default" do
      @user.should_not be_admin
    end

    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
      
    end
    
  end
  
end
