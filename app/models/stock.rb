class Stock < ApplicationRecord
  belongs_to :portfolio
  
  def update_price
    #stocks and funds
    case self.stock_option
    when 'Stock'
      data = Options.stock_price(self.symbol)
    when 'Fund'
      data = Options.yahoo_price(self.symbol)
    when 'Call Option' || 'Put Option'
      option = Options.option_price(self.symbol, self.strike, self.expiration_date, self.stock_option)
        price = self.quantity > 0 ? option['Bid'] : option['Ask']
      data = [ self.symbol.upcase, price, 0, option['Time'] ]
    else
    data = [ 0, 0, 0, Time.parse(data[3]).strftime("%Y/%m/%d %H:%M") ]
    end  
    self.price = data[1]
    self.change = data[2]
    self.as_of = data[3]
    self.save
  end

  def self.refresh_all(stock_option)
    self.all.each do |s|
      if s.stock_option.include?(stock_option)
        s.update_price
      end
    end
  end 


  def self.all_dividend_dates
    dates = [ ]
    (0..11).each do |d|
      date = (Date.today - d.month)
      dates.push [ date.year, date.month ]
    end
    return dates
  end   

#[[1, [["A", 0.149, 707.0], ["AGR", 0.432, 630.0], ["BIF", 0.034, 6242.0], ["CB", 0.71, 1674.0], ["CMCSA", 0.1575, 2260.0], ["CSCO", 0.29, 54616.0], ["DIS", 0.84, 2100.0], ["DLR", 0.93, 1896.0], ["DXC", 0.18, 254.0], ["FCPT", 0.275, 64.0], ["FLS", 0.19, 705.0], ["FLS", 0.19, 705.0], ["GE", 0.12, 2000.0], ["GEF", 0.42, 800.0], ["HIG", 0.25, 360.0], ["HPE", 0.075, 2988.0], ["HPQ", 0.1393, 2988.0], ["HUM", 0.4, 270.0], ["ITW", 0.78, 105.0], ["JPM", 0.56, 1310.0], ["KMB", 0.97, 970.0], ["KSU", 0.36, 300.0], ["MDT", 0.46, 1960.0], ["MO", 0.66, 1786.0], ["MON", 0.54, 900.0], ["MRK", 0.48, 1331.0], ["NKE", 0.2, 6400.0], ["ORCL", 0.19, 1275.0], ["PEP", 0.805, 983.0], ["PGF", 0.08, 23300.0], ["PM", 1.07, 1246.0], ["QLD", "", 14248.0], ["QLD", "", 14248.0], ["SLB", 0.5, 250.0], ["SPY", 1.35133, 1300.0], ["SPY", 1.351333, 1300.0], ["STT", 0.42, 378.0], ["STX", 0.63, 400.0], ["SYK", 0.47, 2130.0], ["TOT", 0.745302, 980.0], ["UMPQ", 0.18, 513.0], ["USB", 0.3, 1000.0], ["WMT", 0.51, 300.0], ["WMT", 0.51, 300.0], ["XRX", 0.25, 250.0]]]

#  def self.total_monthly_dividends(all_divs)
#    monthly = [ ]
#    [5,4,3,2,1,12,11,10,9,8,7,6].each do |month| # each month
#      month_divs = 0
#      all_divs.each do |divs| # scan all dividends
#        divs[1].each do |quart| # look at all quarterlys for monthly
#          if quart[1] == month
#            month_divs += (quart[2] * divs[2]).to_f
#          end
#        end
#      end
#    monthly.push [ month, month_divs]
#		end	
#		return monthly	
#  end

#  def self.annual_dividends(all_divs) # uses the output of self.monthly_dividends(portfolios)
#    totals = [ ]
#      all_divs.each do |divs| # scan all dividends
#        sub = 0
#        divs[1].each do |quart| # look at all quarterlys for monthly
#          sub += (quart[2] * divs[2]).to_f
#        end
#      totals.push [ divs[0], sub]
#		end	
#		return totals	
#  end

# rails g model Dividend symbol:string year:integer month:integer amount:decimal date:datetime
  def self.refresh_dividends
    Dividend.all.delete_all
    syms = Stock.where(stock_option: 'Stock').or(Stock.where(stock_option: 'Fund')).distinct.pluck(:symbol).sort
    syms.each do |sym|      
      stockorfund = Options.yahoo_dividends(sym)
       stockorfund.each do |date_div|
         amount = date_div[1] == '' ? 0 : date_div[1] # check for missing value
           Dividend.create ( { symbol: sym, year: date_div[0][0..3].to_i, month: date_div[0][5..6].to_i, amount: amount, date: date_div[0] } )  
           # divs.push [date_div[0][0..3].to_i, date_div[0][5..6].to_i, amount, date_div[0] ]
       end      
    end
  end

    def self.calc_dividends(portfolios, stock_option_fund)
      stocks_funds = Stock.where(stock_option: stock_option_fund).where(portfolio_id: portfolios)  # .or(Stock.where(stock_option: 'Fund'))
      symbols = stocks_funds.distinct.pluck(:symbol).sort
      all_divs = [ ]
      all_total = 0
      monthly_totals = { }
      (1..12).each { |i| monthly_totals[i] = 0 } # m = "%02d" % i 
      symbols.each do |sym|
        total_year = 0
        quantity = 0
        quantity = stocks_funds.where(symbol: sym).sum(0) { |s| s.quantity.to_f }
        price = Stock.find_by_symbol(sym).price
          stockorfund = Dividend.where(symbol: sym)
          amount = stockorfund.sum(0) { |sf| sf.amount }
            total_year += (amount * quantity)
              divs = stockorfund.collect { |sf| [ sf.year, sf.month, sf.amount, sf.date.strftime('%Y-%m-%d') ] }
              stockorfund.each do |sf|                
                monthly_totals[sf.month] += (sf.amount * quantity)
              end
          annual_yield = 100 * (total_year / ( price * quantity) )
          all_total += total_year
        all_divs.push [sym, divs, quantity, total_year, annual_yield]
      end

      value_total = 0
      stocks_funds.each do |s|
        price = s.price ||= 0
        sub_total = s.quantity * price 
        value_total += sub_total
      end

      current_year = [ ]
        all_dividend_dates.each do |year,month|
          ctotal = 0
          all_divs.each do |sym| # [sym, divs, quantity, total_year, annual_yield]
                                    # divs = [ sf.year, sf.month, sf.amount, sf.date.strftime('%Y-%m-%d') ]
            ctotal += sym[1].select { |d| d[1] == month and d[0] == year }.sum(0) { |t| t[2] * sym[2] }
          end
          current_year.push ctotal.to_f
        end

      return [all_divs, monthly_totals, all_total, value_total, current_year]
    end
  
  
#  def self.yahoo_dividends(portfolios, stock_option_fund)
#    stocks_funds = Stock.where(stock_option: stock_option_fund).where(portfolio_id: portfolios)  # .or(Stock.where(stock_option: 'Fund'))
#    symbols = stocks_funds.distinct.pluck(:symbol).sort
#    all_divs = [ ]
#    all_total = 0
#    monthly_totals = { }
#    (1..12).each { |i| m = "%02d" % i ; monthly_totals[m] = 0 }
#    symbols.each do |sym|
#      total_year = 0
#      quantity = 0
#      divs = [ ]
#      quantity = stocks_funds.where(symbol: sym).sum(0) { |s| s.quantity.to_f }
##      stockorfund = stock_option_fund == 'Stock' ? Options.get_dividends(sym) : Options.yahoo_dividends(sym)
#       stockorfund = Options.yahoo_dividends(sym)
#        stockorfund.each do |date_div|
#          amount = date_div[1] == '' ? 0 : date_div[1] # check for missing value
#          total_year += (amount * quantity)
#            # [["2018-05-11", "0.73"], ["2018-02-09", "0.63"], ["2017-11-10", "0.63"], ["2017-08-10", "0.63"]]
#            divs.push [date_div[0][0..3].to_i, date_div[0][5..6].to_i, amount, date_div[0] ]
#            monthly_totals[date_div[0][5..6]] += (amount * quantity)
#        end
#      all_total += total_year
#      price = Stock.find_by_symbol(sym).price
#      annual_yield = 100 * (total_year / ( price * quantity) )
#      all_divs.push [sym, divs, quantity, total_year, annual_yield]
#    end
#    
#    value_total = 0
#    stocks_funds.each do |s|
#      price = s.price ||= 0
#      sub_total = s.quantity * price 
#      value_total += sub_total
#    end
#    
#    return [all_divs, monthly_totals, all_total, value_total]
#  end
  
#  def self.monthly_dividends(portfolios) # using IEX data
#    stocks_funds = Stock.where(stock_option: 'Stock').where(portfolio_id: portfolios)  # .or(Stock.where(stock_option: 'Fund'))
#    symbols = stocks_funds.distinct.pluck(:symbol).sort
#    divs = [ ]
#    total = 0
#    symbols.each do |sym|
#      dividends = [ ]
#      quantity = stocks_funds.where(symbol: sym).sum(0) { |s| s.quantity.to_f }
#      Options.get_dividends(sym).each do |div|
#        if !div['paymentDate'].blank?
#            dividends.push [div['paymentDate'][0..3].to_i, div['paymentDate'][5..6].to_i, div['amount'], div['paymentDate'] ]
#        end
#      end
#      divs.push [sym, dividends, quantity]
#    end
#    return divs
#  end
   
#  def update_daily_dividend
#      div = Options.check_dividend(self.symbol, Date.today.strftime('%Y-%m-%d')) 
#       self.daily_dividend = div[2] ||= 0
#       self.daily_dividend_date = div[1]
#       self.save      
#  end 
  
#  def self.refresh_all_dividends
#    self.all.each do |s|
#      s.update_daily_dividend
#    end
#  end 

#  def self.refresh_all_dividends
#    i = 0
#    loop do
#        date = (Date.today-i.day).strftime('%Y-%m-%d')
#        puts date
#          self.all.each do |s|
##            puts "#{s.symbol} #{date}"
#            s.update_daily_dividend(date)
#          end
#      i += 1
#      break if i > 200
#    end
#
#    return nil
#  end 

  
  
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


