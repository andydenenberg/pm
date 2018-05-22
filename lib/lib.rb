module Lib
  
  def self.translate_groupids(portfolio_name)
      group = false
      if Portfolio.find_by_name(portfolio_name).nil?
        # not an individual portfolio
        case portfolio_name
        when 'All Portfolios' 
          portfolio_ids = Portfolio.all.collect { |p| p.id }
        else # Group of portfolios
          portfolio_ids = Group.find_by_name(portfolio_name).portfolios.collect { |p| p.id }
          group = true
        end
      else #individual portfolios
          portfolio_ids = Portfolio.find_by_name(portfolio_name).id
      end
    return portfolio_ids, group
  end
  
  # values = [ 29000000, 26000000, 23000000 ]
  def self.graph_scale(values)
    if values.max >    25000000
      max = 35000000 
    elsif values.max > 20000000
      max = 25000000 
    elsif values.max > 15000000
      max = 20000000 
    elsif values.max > 10000000
      max = 15000000 
    elsif values.max >  7000000
      max = 10000000 
    elsif values.max >  5000000
      max = 7000000 
    elsif values.max >  2000000
      max = 5000000 
    elsif values.max >  1000000
      max = 2000000 
    elsif values.max >  500000
      max = 1000000 
    else 
      max = 500000 
    end 
    
    min_val = values.reject {|y| y < 0 }.min # throw out negatives
    if min_val < 500000
      min = 0
    elsif min_val < 1000000
      min = 500000
    elsif min_val < 1500000
      min = 1000000 
    elsif min_val < 2000000
      min = 1500000
    elsif min_val < 3000000
      min = 2000000 
    elsif min_val < 5000000
      min = 3000000 
    elsif min_val < 7000000
      min = 5000000 
    elsif min_val < 10000000
      min = 7000000 
    elsif min_val < 15000000
      min = 10000000 
    else
      min = 15000000
    end
        
    istep = (max - min) / 5    
    if istep < 100000
      step = 50000
    elsif istep <  500000
      step = 200000
    elsif istep <  1000000
      step = 500000
    elsif istep <  5000000
      step = 1000000
    else
      step = 2000000
    end
    
    
#    if max > 25000000
#      min = 15000000
#      step = 2000000
#    end
    
    
    return [ max, min, step ]
    
  end 
end
