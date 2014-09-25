module ApplicationHelper
  
  def parse_package(package)
    package = package.split
    "#{package[0]} <small>#{package[1]}</small><br>".html_safe
  end
    
end
