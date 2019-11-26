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
      data = [ self.symbol.upcase, price, '0', option['Time'] ]
    else
    data = [ 0, 0, 0, Time.parse(data[3]).strftime("%Y/%m/%d %H:%M") ]
    end      
    self.price = data[1].gsub(',','')
    self.change = data[2].gsub(',','')
    self.as_of = data[3]
    self.save
  end

  def self.portfolio_quantities(symbol, pnames)
    self.where(symbol: symbol).collect { |s| #portfolios
       [ pnames[s.portfolio_id], s.quantity ] }.sort_by { |sym, quantity| -quantity }.collect { |sym, quantity| 
        "#{sym}: #{quantity.round.to_s.split(/(?=(?:...)*$)/).join(',')}"}.to_s.gsub('"','').gsub('[','').gsub(']','')
  end
  
  def self.table_data(portfolio_group_name, sort_column, sort_direction)
    portfolios_ids = Lib.translate_groupids(portfolio_group_name).first
    translate = { symbol: 0, value: 2, change: 3, dividends: 7 }
    column = translate[sort_column.to_sym]
    pnames = Portfolio.portfolio_names
    stocks_funds = Stock.where(stock_option: 'Stock').or(Stock.where(stock_option: 'Fund')).where(portfolio_id: portfolios_ids )
    symbols = stocks_funds.distinct.pluck(:symbol)
    values_changes = [ ]
    symbols.each do |sym| 
      s = stocks_funds.where(symbol: sym)
       quantity = s.sum(0) { |q| q.quantity }
       price = s.first.price ||= 0
       change = s.first.change ||= 0
       daily_dividend = s.last.daily_dividend ||= 0
       values_changes.push [  
         sym, #symbol
         quantity, #quantity
         quantity * price, # total value
         quantity * change, # total change in value
         stocks_funds.where(symbol: sym).collect { |stock| stock.portfolio_id }.collect { |id| Portfolio.find(id).name }.join(', '), #portfolio names
         price, # price
         change, # change
         daily_dividend * quantity, # total dividends 
         Stock.portfolio_quantities(sym, pnames), # portfolio holdings 
         daily_dividend, # dividend / share
         s.first.stock_option  
       ]
    end
    stocks = values_changes.sort { |x,y| sort_direction == 'asc' ? y[column] <=> x[column] : x[column] <=> y[column] }
    total_value = stocks.sum(0) { |data| data[2] } 
    total_change = stocks.sum(0) { |data| data[3] }

    return [ stocks, nil, total_value, total_change ]
  end

  def self.table_data_old(portfolio_group_name, sort_column, sort_direction)
      translate = { symbol: 0, value: 2, change: 3, dividends: 7 }
      column = translate[sort_column.to_sym]

      stocks = Stock.where(portfolio_id: Lib.translate_groupids(portfolio_group_name).first )
      stocks_funds = stocks.where(stock_option: 'Stock').or(stocks.where(stock_option: 'Fund'))

      symbols = stocks_funds.distinct.pluck(:symbol)
      values = symbols.collect { |sym| [ sym, stocks_funds.where(symbol: sym).sum(0) { |data| (data.quantity * (data.price ||= 0) ).to_f }] }
      total_value = values.sum(0) { |sym, value| value }.to_f
      change = symbols.collect { |sym| [ sym, stocks_funds.where(symbol: sym).sum(0) { |data| (data.quantity * (data.change ||= 0) ).to_f }] }
      total_change = change.sum(0) { |sym, value| value }.to_f

      stocks = values.collect { |sym, value| [ sym, 
          stocks_funds.where(symbol: sym).sum(0) { |data| data.quantity.to_f },
          value,
          ( (stocks_funds.where(symbol: sym).first.change ||= 0 ) * stocks_funds.where(symbol: sym).sum(0) { |data| data.quantity } ).to_f,
          nil, # stocks_funds.where(symbol: sym).collect { |stock| stock.portfolio_id }.collect { |id| Portfolio.find(id).name }.join(', '),
          stocks_funds.where(symbol: sym).first.price,
          stocks_funds.where(symbol: sym).first.change,
          stocks_funds.where(symbol: sym).sum(0) { |data| (data.quantity * data.daily_dividend).to_f }, # dividends
          stocks_funds.where(symbol: sym).collect { |s| #portfolios
              [ Portfolio.find(s.portfolio_id).name, s.quantity ] }.sort_by { |sym, quantity| -quantity }.collect { |sym, quantity| 
                "#{sym}: #{quantity.round.to_s.split(/(?=(?:...)*$)/).join(',')}"}.to_s.gsub('"','').gsub('[','').gsub(']',''),
          stocks_funds.where(symbol: sym).first.daily_dividend.to_f, # dividend / share

  #     ] }.sort_by {|data| sort_direction == 'asc' ? -data[column] : data[column] }
        ] }.sort { |x,y| sort_direction == 'asc' ? y[column] <=> x[column] : x[column] <=> y[column] } 


       dividends = symbols.collect { |sym| [ sym, stocks_funds.where(symbol: sym).sum(0) { |data| (data.quantity * (data.daily_dividend ||= 0) ).to_f }] }
       dividends = dividends.select { |s,d| d > 0 }.sort_by { |sym, dividend| -dividend }
        
      return [ stocks, dividends, total_value, total_change ]
  end
  
  def self.refresh_all(stock_option)

    uri = URI.parse(ENV["REDISTOGO_URL"])
    REDIS = Redis.new(:url => uri)
    total = self.all.count
    so = self.where("stock_option LIKE ?", "%#{stock_option}%")
    so.each_with_index do |s, i|
      s.update_price
      rs = "#{i}/#{so.count} #{s.symbol}"
      REDIS.set("refresh_status", rs)
      puts rs
    end    
    REDIS.set("refresh_status", 'Complete')

    
    @ironcache = IronCache::Client.new
    @cache = @ironcache.cache("my_cache")
    total = self.all.count
    so = self.where("stock_option LIKE ?", "%#{stock_option}%")
    so.each_with_index do |s, i|
      s.update_price
      rs = "#{i}/#{so.count} #{s.symbol}"
      @cache.put("refresh_status", rs)
      puts rs
    end    
    @cache.put("refresh_status", 'Complete')
    
#   self.all.each do |s|
#     if s.stock_option.include?(stock_option)
#       s.update_price
#     end
#   end    
    
  end 

  def self.current_year_dividend_dates
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
    stocks = Stock.where(stock_option: 'Stock').or(Stock.where(stock_option: 'Fund'))
    syms = stocks.distinct.pluck(:symbol).sort
    syms.each do |sym|      
      stockorfund = Options.yahoo_dividends(sym)
       stockorfund.each do |date_div|
         amount = date_div[1] == '' ? 0 : date_div[1] # check for missing value
           Dividend.create ( { symbol: sym, year: date_div[0][0..3].to_i, month: date_div[0][5..6].to_i, amount: amount, date: date_div[0] } )  
           # divs.push [date_div[0][0..3].to_i, date_div[0][5..6].to_i, amount, date_div[0] ]
       end      
    end
    stocks.each do |s|
      div = Dividend.where(symbol: s.symbol, date: Date.today-1.week..Date.today)
      if !div.empty? 
        s.daily_dividend = div.sum(0) { |d| d.amount }
        s.daily_dividend_date = div.last.date
        s.save
      end
    end
  end

    def self.calc_dividends(portfolio_name, stock_option_fund)
      portfolio_ids = Lib.translate_groupids(portfolio_name).first
      stocks_funds = Stock.where(stock_option: stock_option_fund).where(portfolio_id: portfolio_ids )  # .or(Stock.where(stock_option: 'Fund'))
      symbols = stocks_funds.distinct.pluck(:symbol).sort
      all_divs = [ ]
      all_total = 0
      monthly_totals = { }
      (1..12).each { |i| monthly_totals[i] = 0 } # m = "%02d" % i 
      symbols.each do |sym|
        
        div = Dividend.where(symbol: sym, date: Date.today.beginning_of_month..Date.today)

        current_dividend_date = div.empty? ? nil : div.last.date
        
        total_year = 0
        quantity = 0
        quantity = stocks_funds.where(symbol: sym).sum(0) { |s| s.quantity.to_f }
        price = Stock.find_by_symbol(sym).price ||= 0
          stockorfund = Dividend.where(symbol: sym)
          amount = stockorfund.sum(0) { |sf| sf.amount }
            total_year += (amount * quantity)
              divs = stockorfund.collect { |sf| [ sf.year, sf.month, sf.amount, sf.date.strftime('%Y-%m-%d') ] }
              stockorfund.each do |sf|                
                monthly_totals[sf.month] += (sf.amount * quantity)
              end
          annual_yield = 100 * (total_year / ( price * quantity) )
          all_total += total_year
        all_divs.push [ sym, divs, quantity, total_year, annual_yield, current_dividend_date ]
      end

      value_total = 0
      stocks_funds.each do |s|
        price = s.price ||= 0
        sub_total = s.quantity * price 
        value_total += sub_total
      end

      current_year = [ ]
        current_year_dividend_dates.each do |year,month|
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


