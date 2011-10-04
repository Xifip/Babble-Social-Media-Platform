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
   
  def checklist(name, collection, value_method, display_method, selected)
    selected ||= []
    
    ERB.new(%{
    <div class="checklist" style="border:1px solid #ccc; width:25em; height:6em; overflow:auto">
      <% for item in collection %>
        <%= check_box_tag name, item.send(value_method), selected.include?(item.send(value_method)), :id => item.send(display_method).gsub(/\s+/, "") %> <%= item.send(display_method) %><br />
      <% end %>
    </div>}).result(binding).html_safe
  end
  
  def is_active?(link)
    "current_path" if current_page?(link) 
  end
  
  def pageless(total_pages, url=nil, container=nil)
    opts = {
      :totalPages => total_pages,
      :url        => url,
      :loaderMsg  => 'Loading ...'
    }
    
    container && opts[:container] ||= container
    
    
    javascript_tag("
          (function ($) { 
              $('#paged_content').pageless(#{opts.to_json});  
          })(jQuery)")
  end
  
end
