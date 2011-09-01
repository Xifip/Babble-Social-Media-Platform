require 'spec_helper'

describe "Relationships" do
  
  before(:each) do
    user = Factory(:user)
    @user2 = Factory(:user, :email => Factory.next(:email))
    visit signin_path
    fill_in :email, :with => user.email
    fill_in :password, :with => user.password
    click_button
  end
  
  describe "following" do
    
    describe "success" do     
      
      it "user should follow user 2" do
        lambda do
          visit user_path(@user2.id)
          click_button
        end.should change(Relationship, :count).by(1)
      end
      
    end    
    
  end
  
  describe "unfollowing" do
    
    before(:each) do
      visit user_path(@user2.id)
      click_button
    end
    
    describe "success" do
      
      it "user should unfollow user 2" do
        lambda do
          visit user_path(@user2.id)
          click_button
        end.should change(Relationship, :count).by(-1)
      end   
      
    end    
       
  end
  
end
