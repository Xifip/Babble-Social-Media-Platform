# To change this template, choose Tools | Templates
# and open the template in the editor.

class MicropostsController < ApplicationController
  before_filter :authenticate, :only => [:create, :destroy, :index]
  before_filter :authorized_user, :only => :destroy
  
  def create
    @micropost = current_user.microposts.build(params[:micropost])
    if @micropost.save
      flash[:success] = "Micropost created !"
      
      current_user.publish(@micropost.content) if @micropost.tweet_now == "1"
      
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
  
  private
  def authorized_user
    @micropost = current_user.microposts.find(params[:id])
  rescue
    redirect_to root_path
  end
  
end
