class Portfolio < ApplicationRecord
  belongs_to :group
  has_many :stocks, :dependent => :destroy  
  has_many :histories, :dependent => :destroy  
  
  def self.table_data(group_id)
    totals = Hash.new
    all = group_id.nil? ? Portfolio.all : Portfolio.where(group_id: group_id)
    all.each { |p| totals[p.id] = (p.cash + p.total_stocks_value + p.total_options_value).to_f }
    ordered = Portfolio.find(totals.sort_by { |key, value | -value }.collect { |id, value| id })
    total_cash = all.sum { |s| s.cash }
    total_stocks = all.sum { |s| s.total_stocks_value }
    total_stocks_change = all.sum { |s| s.total_stocks_change_value }
    total_options = all.sum { |s| s.total_options_value }
    total_dividends = all.sum { |s| s.total_dividends_value }
    last_update = Stock.where(stock_option: 'Stock').last.updated_at
    return [ordered, total_cash, total_stocks, total_options, total_stocks_change, last_update, total_dividends ]      
  end
  
  def self.stocks_total(name)
    stocks = Options.portfolio_total_stocks(name)
  end
  
  def total_stocks_value
    total = 0
    stocks = self.stocks.where(:stock_option => 'Stock').or(self.stocks.where(:stock_option => 'Fund'))
    stocks.each do |s|
      price = s.price ||= 0
      sub_total = s.quantity * price 
      total += sub_total
    end
    return total
  end

  def total_stocks_change_value
    total = 0
    stocks = self.stocks.where(:stock_option => 'Stock').or(self.stocks.where(:stock_option => 'Fund'))
    stocks.each do |s|
      change = s.change ||= 0
      total += s.quantity * change
    end
    return total
  end
  
  def total_options_value
    total = 0
    options = self.stocks.where(:stock_option => 'Call Option').or(self.stocks.where(:stock_option => 'Put Option'))
    options.each do |s|
      total += s.quantity * s.price * 100
    end
    return total    
  end
  
  def total_dividends_value
    total = 0
    stocks = self.stocks.where(:stock_option => 'Stock').or(self.stocks.where(:stock_option => 'Fund'))
    stocks.each do |s|
      total += s.quantity * s.daily_dividend
    end
    return total    
  end

end

#   rails g scaffold Portfolio name:string cash:decimal

