require 'spec_helper'

describe "Microposts" do
  
  before(:each) do
    user = Factory(:user)
    visit signin_path
    fill_in :email, :with => user.email
    fill_in :password, :with => user.password
    click_button
  end
  
  describe "creation" do
    
    describe "failure" do
      
      it "should not make a new micropost" do
        lambda do
          visit root_path
          fill_in :micropost_content, :with => ""
          submit_form 'new_micropost'
          response.should render_template('pages/home')
          response.should have_selector("div#error_explanation")
        end.should_not change(Micropost, :count)
      end      
    end
    
    describe "success" do
      
      it "should create a new micropost" do
        lambda do
          visit root_path
          fill_in :micropost_content, :with => "Some randomness"
          submit_form 'new_micropost'
          response.should have_selector("li>div>div>h4", :content => "Some randomness")          
        end.should change(Micropost, :count).by(1)        
      end
    end
    
  end
  
end
