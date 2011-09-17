class SentController < ApplicationController
    
  before_filter :authenticate   
  
  def index
    @title = "Sent Messages"
    @messages = current_user.sent_messages.paginate(:per_page => 15, 
      :page => params[ :page ], :order => "created_at DESC")
  end

  def show
    @message = current_user.sent_messages.find(params[:id])
    @title = @message.subject
  end

  def new
    @title = "New Message"
    @message = current_user.sent_messages.new
  end
  
  def create
    @message = current_user.sent_messages.new(params[:message])
    
    if @message.save
      flash[:success] = 'Message sent !'
      redirect_to :action => "index"
    else
      @title = "New Message"
      render :action => "new"
    end
    
  end

end
