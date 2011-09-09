class LikesController < ApplicationController
  
  before_filter :authenticate  
  
  def create
    @micropost = User.find(params[:like][:liked_id])
    current_user.like!(@micropost)
    redirect_back_or request.referrer
    
  end
  
  def destroy
    @micropost = Like.find(params[:id]).liked
    current_user.unlike!(@micropost)
    redirect_back_or request.referrer
  end
  
end