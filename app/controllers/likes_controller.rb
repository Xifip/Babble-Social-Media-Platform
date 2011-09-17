class LikesController < ApplicationController
  
  before_filter :authenticate  
  before_filter :allowed_to_like, :only => :create
  before_filter :allowed_to_unlike, :only => :destroy
    
  def create
    @micropost = Micropost.find(params[:like][:liked_id])
    
    current_user.like!(@micropost)
    
    respond_to do |format|
      format.html { redirect_to request.referrer}
      format.js
    end                
  end
  
  def destroy
    @micropost = Like.find(params[:id]).liked
    
    current_user.unlike!(@micropost)  

    respond_to do |format|
      format.html { redirect_to request.referrer}
      format.js
    end    
    
  end
  
  private
  
  def allowed_to_like
    @user = Micropost.find(params[:like][:liked_id]).user
    redirect_to request.referrer  if current_user?(@user)
  end
  
  def allowed_to_unlike
    @likes_user = Like.find(params[:id]).liker
    redirect_to request.referrer unless current_user?(@likes_user)
  end
  
end