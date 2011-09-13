class LikesController < ApplicationController
  
  before_filter :authenticate  
    
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
  
end