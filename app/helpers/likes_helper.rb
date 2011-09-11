module LikesHelper

  def likes_text_for(micropost)
    if micropost.likes_count == 0 
      "Like"
    else
      pluralize(micropost.likes_count, "Like") 
    end
  end
  
end