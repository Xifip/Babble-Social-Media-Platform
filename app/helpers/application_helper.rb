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
end
