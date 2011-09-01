require 'spec_helper'

describe "Relationships" do
  
  before(:each) do
    @user1 = Factory(:user)
    @user2 = Factory(:user, :email => Factory.next(:email))
    visit signin_path
    fill_in :email, :with => @user1.email
    fill_in :password, :with => @user1.password
    click_button
  end
  
  describe "following" do
    
    describe "success" do     
      
      it "user should follow user 2" do
        lambda do
          visit user_path(@user2)
          click_button
        end.should change(Relationship, :count).by(1)
      end
      
      it "user's following page should have user2" do
        visit user_path(@user2)
        click_button
        visit following_user_path(@user1)
        response.should have_selector("li>div>strong", :content => @user2.name)          
      end
      
      it "user2's follwers page should have user" do
        visit user_path(@user2)
        click_button
        visit followers_user_path(@user2)
        response.should have_selector("li>div>strong", :content => @user1.name) 
      end
      
    end    
    
  end
  
  describe "unfollowing" do
    
    before(:each) do
      visit user_path(@user2)
      click_button
    end
    
    describe "success" do
      
      it "user should unfollow user 2" do
        lambda do
          visit user_path(@user2)
          click_button
        end.should change(Relationship, :count).by(-1)
      end   
      
      it "user's following page should not have user2" do
        visit user_path(@user2)
        click_button
        visit following_user_path(@user1)
        response.should_not have_selector("li>div>strong", :content => @user2.name)          
      end
      
      it "user2's follwers page should not have user" do
        visit user_path(@user2)
        click_button
        visit followers_user_path(@user2)
        response.should_not have_selector("li>div>strong", :content => @user1.name) 
      end
      
    end    
       
  end
  
end
