module UsersHelper
  
  def gravatar_for(user, options = { :size => 50})
    if user.provider == "twitter"
      
      image_tag(user.twitter_img_url, :alt => user.name, :class => 'gravatar',
        :height => options[:size], :width => options[:size])
      
    else
      gravatar_image_tag(user.email.downcase, :alt => user.name, :class => 'gravatar', :gravatar => options)
    end    
  end
  
end
