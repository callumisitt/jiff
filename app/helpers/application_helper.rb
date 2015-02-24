module ApplicationHelper
  
  def parse_package(package)
    package = package.split
    "<span data-package=\"#{package[0].remove('.')}\">#{package[0]} <small>#{package[1]}</small></span><br>".html_safe
  end
    
end
