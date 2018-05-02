module Lib
  
  def self.translate_groupids(portfolio_name)
    
      if Portfolio.find_by_name(portfolio_name).nil?
        # not an individual portfolio
        case portfolio_name
        when 'All Portfolios' 
          portfolio_ids = Portfolio.all.collect { |p| p.id }
        else # individual portfolios
          portfolio_ids = Group.find_by_name(group_name).portfolios.collect { |p| p.id }
        end
      else # Group of portfolios
        portfolio_ids = Group.find_by_name(group_name).portfolios.collect { |p| p.id }
      end
    return portfolio_ids
  end
  
end
