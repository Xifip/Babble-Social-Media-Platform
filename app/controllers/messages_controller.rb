class MessagesController < ApplicationController
  
  before_filter :authenticate
  before_filter :correct_user
  
  def show
    @message = current_user.received_messages.find(params[:id])
    @message.unread = false
    @message.save
  end
  
  def reply
    original_message = current_user.received_messages.find(params[:id])    
    message_do(:reply, original_message)    
  end
  
  def reply_all
    original_message = current_user.received_messages.find(params[:id])
    message_do(:reply_all, original_message)
  end
  
  def forward
    original_message = current_user.received_messages.find(params[:id])    
    message_do(:forward, original_message)    
  end
  
  def set_read_state
    
    original_message = current_user.received_messages.find(params[:id])
    original_message.unread = !original_message.unread
    original_message.save!
    
    redirect_to inbox_path
    
  end
  
  private
  
  def correct_user
    @user = MessageCopy.find(params[:id]).recipient
    redirect_to request.referrer  unless current_user?(@user)
  end
  
  def message_do(action, original_message)
    
    if (action == :reply || action == :reply_all)
      
      subject = original_message.subject.sub(/^(Re: )?/, "Re: ")
      body = original_message.body.gsub(/^/, "> ")
      
      if (action == :reply)
        @message = current_user.sent_messages.build(:to => [original_message.author.id], :subject => subject, :body => body)
      else
        recipients = original_message.recipients.map(&:id) - [current_user.id] + [original_message.author.id] 
        @message = current_user.sent_messages.build(:to => recipients, :subject => subject, :body => body)
      end
      
      
    elsif (action == :forward)
      
      subject = original_message.subject.sub(/^(Fw: )?/, "Fw: ")
      body = original_message.body.gsub(/^/, "> ")
      @message = current_user.sent_messages.build(:to => [], :subject => subject, :body => body)      
      
    end
    
    @title = subject
    
    render :template => "sent/new"
    
  end
  

end
