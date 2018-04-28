module ApplicationHelper
  
  def sortable(column, title = nil)
    title ||= column.titleize # make it look pretty

    if column == sort_column 
      if sort_direction == 'asc'
        title = title + '<span data-feather="chevron-down"></span>'
      else
      title = title + '<span data-feather="chevron-up"></span>'
      end
    end
    
    direction = column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
    
    link_to title.html_safe, { :sort => column, :direction => direction } , {:class => ''}
  end
  
end
