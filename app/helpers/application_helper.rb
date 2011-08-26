module ApplicationHelper
  
  #function for returning a title
  def title
    base_title = "Babble"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end
  
  def logo
    logo = image_tag("babble_logo.png", :alt => "Babble", :class => "")    
  end
  
end
