module ApplicationHelper
  def sortable(portfolio_name, column, title = nil)
    title ||= column.titleize # make it look pretty

    if column == sort_column 
      if sort_direction == 'asc'
        title = title + '<span data-feather="chevron-down"></span>'
      else
      title = title + '<span data-feather="chevron-up"></span>'
      end
    end
    
    direction = column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
    
    link_to title.html_safe, { portfolio_name: portfolio_name,  :sort => column, :direction => direction } , {:class => ''}
  end
  
end
