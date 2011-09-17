class MessagesController < ApplicationController
  
  before_filter :authenticate
  before_filter :correct_user
  
  def show
    @message = current_user.received_messages.find(params[:id])
  end
  
  private
  
  def correct_user
    @user = MessageCopy.find(params[:id]).recipient
    redirect_to request.referrer  unless current_user?(@user)
  end
  

end
