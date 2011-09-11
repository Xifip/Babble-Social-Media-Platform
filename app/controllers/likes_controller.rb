class LikesController < ApplicationController
  
  before_filter :authenticate  
  respond_to :html, :js
  
  def create
    @micropost = Micropost.find(params[:like][:liked_id])
    @this_user = User.find_by_id(@micropost.user_id)
    current_user.like!(@micropost)
    respond_with @this_user
    
  end
  
  def destroy
    @micropost = Like.find(params[:id]).liked
    @this_user = User.find_by_id(@micropost.user_id)
    current_user.unlike!(@micropost)
    respond_with @this_user
  end
  
end