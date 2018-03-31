class Portfolio < ApplicationRecord
#  belongs_to :user
  has_many :stocks, :dependent => :destroy
  
  def self.stocks_total(name)
    stocks = Options.portfolio_total_stocks(name)
  end
  
  def total_stocks
    total = 0
    stocks = self.stocks.where(:stock_option => 'Stock')
    stocks.each do |s|
      price = Options.stock_price(s.symbol)[1]
      if price.nil? 
        price = Options.yahoo_price(s.symbol)
        s.stock_option = 'Fund'  
        s.save
      end
        total += price.to_f * s.quantity
    end
    return total
  end
  
end

#   rails g scaffold Portfolio name:string cash:decimal

