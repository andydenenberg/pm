class Portfolio < ApplicationRecord
#  belongs_to :user
  has_many :stocks, :dependent => :destroy  
  has_many :histories, :dependent => :destroy  
  
  def self.stocks_total(name)
    stocks = Options.portfolio_total_stocks(name)
  end
  
  def total_stocks_value
    total = 0
    stocks = self.stocks.where(:stock_option => 'Stock').or(self.stocks.where(:stock_option => 'Fund'))
    stocks.each do |s|
      total += s.quantity * s.price
    end
    return total
  end

  def total_stocks_change_value
    total = 0
    stocks = self.stocks.where(:stock_option => 'Stock').or(self.stocks.where(:stock_option => 'Fund'))
    stocks.each do |s|
      total += s.quantity * s.change
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

