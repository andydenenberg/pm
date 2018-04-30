module Lib
  
  def self.translate_groupids(portfolio_name)
    
    case portfolio_name
      when 'All Portfolios' 
        portfolio_ids = Portfolio.all.collect { |p| p.id }
      when 'Personel Portfolios'
        portfolio_ids = Portfolio.where(group_id: 1).collect { |p| p.id }
      when 'All SLATs'
        portfolio_ids = Portfolio.where(group_id: 2).collect { |p| p.id }
      when 'Retirement Portfolios'
        portfolio_ids = Portfolio.where(group_id: 3).collect { |p| p.id }
      else
        portfolio_ids = [Portfolio.find_by_name(portfolio_name).id]
      end
    return portfolio_ids
  end
  
end
