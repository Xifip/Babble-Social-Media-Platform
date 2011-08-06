require 'spec_helper'

describe "FriendlyForwardings" do
  
  it "should redirect to the requested edit page after signin" do
    
    user = Factory(:user)
    visit edit_user_path(user)
    
    #the integration test will redirect to the sign in page thanks to the
    #authenticate method on the user controller, which calls deny_access, which 
    #does the actual redirecting
    
    fill_in :email, :with => user.email
    fill_in :password, :with => user.password
    click_button
    
    #the app should redirect to the edit path after signing in
    response.should render_template('users/edit')
    
  end
  
end
