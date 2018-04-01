class Stock < ApplicationRecord
  belongs_to :portfolio
  
  def update_price
    #stocks and funds
    case self.stock_option
    when 'Stock'
      data = Options.stock_price(self.symbol)
    when 'Fund'
      data = Options.yahoo_price(self.symbol)
    else 
      option = Options.option_price(self.symbol, self.strike, self.expiration_date, self.stock_option)
        price = self.quantity > 0 ? option['Bid'] : option['Ask']
      data = [ self.symbol.upcase, price, 0, option['Time'] ]
    end        
    self.price = data[1]
    self.as_of = data[3]
    self.save
  end
   
  def self.refresh_all_prices
    self.all.each do |s|
      s.update_price
    end
  end 
  
  def check_if_fund
    if self.stock_option == 'Stock'
      price = Options.stock_price(self.symbol)[1]
      if price.nil? 
        price = Options.yahoo_price(self.symbol)[1]
         if !price.nil?
           self.stock_option = 'Fund'  
           self.save
         end
      end 
    end   
  end

  def self.check_all_for_funds
    self.all.each do |s|
      s.check_if_fund
    end
  end
  
end

#   rails g scaffold Stock purchase_price:decimal quantity:decimal symbol:string name:string purchase_date:string strike:decimal expiration_date:string stock_option:string

