class LikesController < ApplicationController
  
  before_filter :authenticate  
  respond_to :html, :js
  
  def create
    @micropost = Micropost.find(params[:like][:liked_id])
    
    current_user.like!(@micropost)
    
    likes_controller_response
        
  end
  
  def destroy
    @micropost = Like.find(params[:id]).liked
    
    current_user.unlike!(@micropost)
    
    likes_controller_response
  end
  
end