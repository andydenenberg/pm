class Portfolio < ApplicationRecord
#  belongs_to :user
  has_many :stocks, :dependent => :destroy  
  
  def self.stocks_total(name)
    stocks = Options.portfolio_total_stocks(name)
  end
  
  def total_stocks
    total = 0
    stocks = self.stocks.where(:stock_option => 'Stock').or(self.stocks.where(:stock_option => 'Fund'))
    puts stocks.count
    stocks.each do |s|
      total += s.quantity * s.price
    end
    return total
  end

  def total_stocks_change
    total = 0
    stocks = self.stocks.where(:stock_option => 'Stock').or(self.stocks.where(:stock_option => 'Fund'))
    puts stocks.count
    stocks.each do |s|
      total += s.quantity * s.change
    end
    return total
  end
  
  def total_options
    total = 0
    options = self.stocks.where(:stock_option => 'Call Option').or(self.stocks.where(:stock_option => 'Put Option'))
    puts options.count
    options.each do |s|
      total += s.quantity * s.price * 100
    end
    return total
    
  end
end

#   rails g scaffold Portfolio name:string cash:decimal

