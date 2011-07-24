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
    @attr = {:name => "test name", :email => "abc@gmail.com"}
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
    attributes = { :name => "tester", :email => "blah@same.com" }
    User.create! (attributes)
    user2 = User.new (attributes)
    user2.should_not be_valid
  end
  
  it "should reject users with the same email address, irrespective of case" do
    attributes = { :name => "tester", :email => "blah@sameCASEINSEN.com" }
    User.create! (attributes)
    user2 = User.new (attributes.merge(:email => attributes[:email].upcase))
    user2.should_not be_valid
  end
  
end
