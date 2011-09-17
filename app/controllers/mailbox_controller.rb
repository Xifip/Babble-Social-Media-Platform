class MailboxController < ApplicationController
  
  before_filter :authenticate
  before_filter :correct_user, :only => [:show]
  
  def index
    
    @folder = current_user.inbox    
    show
    render :action => "show"
    
  end

  def show
    
    @folder ||= current_user.folders.find(params[:id])
    @title = @folder.name
    @messages = @folder.messages.paginate(
      :per_page => 10, 
      :page => params[:page], 
      :include => :message, 
      :order => "messages.created_at DESC"
    ) 
    
  end

  private
  
  def correct_user
    @user = Folder.find(params[:id]).user
    redirect_to request.referrer  unless current_user?(@user)
  end
  
end
