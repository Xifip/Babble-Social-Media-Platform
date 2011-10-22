class PagesController < ApplicationController
  def home
    
    set_up_signed_in_home(:feed)
    
    if request.xhr?
      render :partial => 'shared/feed_item', :collection => @feed_items
    end
    
  end
  
  def recent
    
    set_up_signed_in_home(:recent)
    
    if request.xhr?
      render :partial => 'shared/feed_item', :collection => @feed_items
    else
      render 'home'
    end
    
  end

  def contact
    @title = "Contact"
  end
  
  def about
    @title = "About"
  end
  
  def help
    @title = "Help"
  end
  
  private
  
  def set_up_signed_in_home(feed_or_recent)
    if signed_in?
      if (feed_or_recent == :feed)
        @feed_items = current_user.feed.paginate(:page => params[:page], :per_page => 10)
      elsif (feed_or_recent == :recent)
        @feed_items = Micropost.all.paginate(:page => params[:page], :per_page => 10)
      end
      @micropost = Micropost.new
      @micropost_rotated_image = Micropost.random_where('photo_file_name is NOT NULL')
      @recent_trending_items = Micropost.recent_most_popular
      
    else
      @feed_items = Micropost.all.paginate(:page => params[:page], :per_page => 10)
    end
    
    @title = "Home"
    
  end

end