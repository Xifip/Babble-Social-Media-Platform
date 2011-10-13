# To change this template, choose Tools | Templates
# and open the template in the editor.

class MicropostsController < ApplicationController
  before_filter :authenticate, :only => [:create, :destroy, :index]
  before_filter :authorized_user, :only => :destroy
  
  def create
    @micropost = current_user.microposts.build(params[:micropost])
    if @micropost.save
      flash[:success] = "Micropost created !"
      
      if @micropost.tweet_now == "1"
        current_user.publish(@micropost.content << " " << user_micropost_url(current_user,@micropost))
      end
            
      redirect_to request.referrer
    else
      @feed_items = []
      render 'pages/home'
    end
  end
  
  def destroy
    @micropost.destroy
    redirect_back_or request.referrer
  end
  
  def index
    redirect_to root_path
  end  
  
  def show
    
    @user = User.find(params[:user_id])
    
    if signed_in? && current_user?(@user)
      @micropost = Micropost.new
    end
    
    begin
      microposts_prepage = [@user.microposts.find(params[:id])]
    rescue
      microposts_prepage = []
    end
        
    if microposts_prepage.empty?
      redirect_to root_path
    else
      @microposts = microposts_prepage.paginate(:page => params[:page])
      render 'users/show'
    end   
    
  end
  
  private
  def authorized_user
    @micropost = current_user.microposts.find(params[:id])
  rescue
    redirect_to root_path
  end
  
end
