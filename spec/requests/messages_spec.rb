require 'spec_helper'

describe "Messages" do
  
  
  before(:each) do
    @user = Factory(:user)
    @user2 = Factory(:user, :email => Factory.next(:email))
    @user3 = Factory(:user, :name => "James ffolliot", :email => Factory.next(:email))
    @user4 = Factory(:user, :name => "Jeff Williamson", :email => Factory.next(:email))    
    visit signin_path
    fill_in :email, :with => @user.email
    fill_in :password, :with => @user.password
    click_button
  end
  
  describe "creation" do
    
    describe "failure" do
      
      it "should not make a new message" do
        lambda do
          visit new_sent_path
          fill_in :message_body, :with => ""
          click_button
          response.should render_template('sent/new')
          response.should have_selector("div#error_explanation")
        end.should_not change(Message, :count)
      end      
    end
    
    describe "success" do
      
      it "should create a new message" do
        lambda do
          visit new_sent_path
          check('LloydChan')
          fill_in :message_subject, :with => "Random"
          fill_in :message_body, :with => "Some randomness"          
          click_button        
        end.should change(Message, :count).by(1)        
      end
  
      it "should create a 2 new message copy with 2 recipients selected" do
        lambda do
          visit new_sent_path
          check('LloydChan')
          check('Jamesffolliot')
          fill_in :message_subject, :with => "Random"
          fill_in :message_body, :with => "Some randomness"          
          click_button        
        end.should change(MessageCopy, :count).by(2)        
      end      
      
    end
    
  end
  
  describe "responding and forwarding" do
    
    before(:each) do
      # send 1 messages to James folliot and JeffWilliamson, signout and relogin as James
      visit new_sent_path      
      check('Jamesffolliot')
      check('JeffWilliamson')
      fill_in :message_subject, :with => "Random Subject"
      fill_in :message_body, :with => "Some randomness"          
      click_button
      visit signout_path
      visit signin_path
      fill_in :email, :with => @user3.email
      fill_in :password, :with => @user3.password
      click_button 
    end
    
    it "should reply to a message" do
      visit inbox_path
      click_link 'Random Subject'
      click_button 'Reply'
      response.should render_template('sent/new')
    end
    
    it "should create a new Message object as a result of replying" do
      lambda do
        visit inbox_path
        click_link 'Random Subject'
        click_button 'Reply'
        click_button 'Send'
      end.should change(Message, :count).by(1)
    end    
    
    it "should forward a message" do
      visit inbox_path
      click_link 'Random Subject'
      click_button 'Forward'
      response.should render_template('sent/new')
    end
    
    it "should create a new Message object as a result of forwarding" do
      lambda do
        visit inbox_path
        click_link 'Random Subject'
        click_button 'Forward'
        check('LloydChan')
        check('Jamesffolliot')
        click_button 'Send'
      end.should change(Message, :count).by(1)
    end    
    
    it "should reply all to a message" do
      visit inbox_path
      click_link 'Random Subject'
      click_button 'Reply all'
      response.should render_template('sent/new')
    end
    
    it "should create a new Message object and 2 MessageCopies as a result of replying" do
      lambda do
        visit inbox_path
        click_link 'Random Subject'
        click_button 'Reply all'
        click_button 'Send'
      end.should change(Message, :count).by(1) and change(MessageCopy, :count).by(2)
    end    
    
    
  end  
  
  
  describe "message count labels" do
    
    before(:each) do
      # send 2 messages to James folliot, signout and relogin as James
      visit new_sent_path      
      check('Jamesffolliot')
      fill_in :message_subject, :with => "Random"
      fill_in :message_body, :with => "Some randomness"          
      click_button
      visit new_sent_path      
      check('Jamesffolliot')
      fill_in :message_subject, :with => "Random2"
      fill_in :message_body, :with => "Some randomness2"          
      click_button
      visit signout_path
      visit signin_path
      fill_in :email, :with => @user3.email
      fill_in :password, :with => @user3.password
      click_button      
    end
    
    it "should have the proper unread messages count for James" do
      visit inbox_path
      response.should have_selector('a', :href => inbox_path, :content => "Messages (2)")      
      response.should have_selector('a', :href =>inbox_path, :content => "Inbox (2)")      
    end
    
    it "should have the proper unread messages count for James after reading the message" do
      visit inbox_path
      click_link 'Random'
      response.should have_selector('a', :href => inbox_path, :content => "Messages (1)")
      visit inbox_path
      response.should have_selector('a', :href => inbox_path, :content => "Inbox (1)")
      click_link 'Random2'
      response.should have_selector('a', :href => inbox_path, :content => "Messages")
      visit inbox_path
      response.should have_selector('a', :href => inbox_path, :content => "Inbox")
    end
    
  end
  
end
