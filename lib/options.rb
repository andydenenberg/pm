# namespace :cboe do
#  task :options => :environment do

module Options
  require 'csv'
  require 'open-uri'

# Get current stock price from Yahoo Finance 
# method is optimized to pack requests in groups of up to 100 symbols
# expects and array of symbol strings 

#  def self.stock_price(symbols) 
#    list = symbols.join(',')
#    url = "http://download.finance.yahoo.com/d/quotes.csv?s=#{list}&f=snl1d1t1c1&e=.csv"
#    sym_list = [ ]
#    begin
#      doc = open(url)     
#      got_data = doc.read
#      t = symbols.length
#      t.times do |j|
#        data = CSV.parse(got_data)[j-1]
#        current_price = { }
#        ['Symbol', 'Name', 'LastTrade', 'LastTradeDate', 'LastTradeTime', 'Change' ].each_with_index { |title, i| current_price[title] = data[i] }
        
#        date = current_price['LastTradeDate'].match(/(\d{1,2})\/(\d{1,2})\/(\d{4})/)
#        if !date.nil?
#          # create rails compatible data format - LastUpdate
#          current_price['LastUpdate'] = date[3] + '/' + date[1] + '/' + date[2] + ' ' + current_price['LastTradeTime']
#          current_price['Error'] = nil
#        else
#          current_price['Error'] = 'Symbol not found.'
#        end
#        sym_list.push current_price
#       end
#      return sym_list
#
#    rescue Timeout::Error
#      return ["The request timed out...skipping."]
#    rescue => e
#      return ["The request returned an error - #{e.inspect}."]
#    end      
#  end  

#  def self.stock_price(symbol)
#    require "net/http"
#    require "uri"
#    require 'rubygems'
#    require 'mechanize'
#    require 'json'
#    require 'nokogiri'
#
#    @agent = Mechanize.new 
#
#     url = "https://finance.google.com/finance?q=NYSE:#{symbol.upcase}"    
#     puts url
#             begin
#               page = @agent.get(url)
#             rescue Errno::ETIMEDOUT, Timeout::Error, Net::HTTPNotFound, Mechanize::ResponseCodeError
#               puts '\n\n\nRetrying...\n\n\n'
#               page = @agent.get(url)
#             end  
#             payload = page.body    
#             doc = Nokogiri::HTML(payload)             
#             last_price = doc.xpath('//span[@class="pr"]')             
#             if !last_price.empty?
#               last_price = last_price.children.to_s.split('">').last.gsub("</span>\n",'')
#               change = doc.xpath('//span[@class="ch bld"]').children.first.to_s.split('">').last.gsub("</span>",'').gsub('+','')             
#               time = Time.now.strftime("%Y/%m/%d %H:%M")
#               ret = [symbol.upcase, last_price, change, time]
#             else
#               ret = [ ]
#             end  
#  end

  def self.portfolio_total_stocks(portfolio_name)
      total = 0
      stocks = Portfolio.find_by_name(portfolio_name).stocks.where(:stock_option => 'Stock')
      stocks.each do |s|
#        puts total
        price = Options.stock_price(s.symbol)[1]
        if price.nil? 
          price = Options.yahoo_price(s.symbol)
#          puts s.symbol + ' - ' +s.stock_option+ ' is a Mutual Fund  - price:' + price
          s.stock_option = 'Fund'  
          s.save
        end
          total += price.to_f * s.quantity
#        total += Options.yahoo_price(s.symbol).to_f * s.quantity
      end
      return total
  end
  
  
#   <span class="Trsdu(0.3s) Fw(b) Fz(36px) Mb(-4px) D(ib)" data-reactid="35"><!-- react-text: 36 -->16.39<!-- /react-text --></span>
#   <td class="C(black) W(51%)" data-reactid="38"><span data-reactid="39">Previous Close</span></td>
 
  def self.yahoo_price(symbol)     
    @agent = Mechanize.new 
    url = "http://finance.yahoo.com/quote/#{symbol}?p=#{symbol}"
    begin
      page = @agent.get(url)  
      doc = Nokogiri::HTML(page.body) 
      price = page.xpath('.//span[contains(@class,"Trsdu(0.3s) Fw(b)")]//text()')
    rescue Errno::ETIMEDOUT, Timeout::Error, Net::HTTPNotFound, Mechanize::ResponseCodeError
      return ["The request timed out...skipping."]
    rescue => e
      return ["The request returned an error - #{e.inspect}."]
    end     
    return price.to_s         
  end  
  
  
  def self.yahoo_summary(symbol)     
    @agent = Mechanize.new 
    url = "http://finance.yahoo.com/quote/#{symbol}?p=#{symbol}"
    begin
      page = @agent.get(url)  
      doc = Nokogiri::HTML(page.body) 
      keys = page.xpath('.//td[contains(@class,"C(black)")]//text()')
      values = page.xpath('.//td[contains(@class,"Ta(end)")]//text()')
      data = [ ]
      keys.each_with_index do |key, i| 
        data += [ key.to_s + ': ' + values[i].to_s ]
      end
      data.each do |d|
        puts d
      end
    rescue Errno::ETIMEDOUT, Timeout::Error, Net::HTTPNotFound, Mechanize::ResponseCodeError
      return ["The request timed out...skipping."]
    rescue => e
      return ["The request returned an error - #{e.inspect}."]
    end     
    return nil         
  end  
  
  
  def self.stock_price(symbol)  
    url = "https://api.iextrading.com/1.0/stock/#{symbol.upcase}/quote" 
    @agent = Mechanize.new
    ret = [ ]
      begin
        page = @agent.get(url)
        data = JSON.parse(page.body) 
        last_price = data['latestPrice'].to_s
        change = data["change"].to_s
        time = data["latestTime"]
        ret = [symbol.upcase, last_price, change, time]
      rescue Errno::ETIMEDOUT, Timeout::Error, Net::HTTPNotFound, Mechanize::ResponseCodeError
#        puts "#{symbol} - Unknown Response"
      end       
    return ret
  end 
    
 
 
    def self.refresh_stocks      
      dead = [ ]
      
      Price.where(:sec_type => 'Stock').each do |stock|
            result = self.stock_price(stock.symbol)
          if !result.empty?
            stock.last_price = result[1].gsub(',','').to_f
            stock.last_update = result[3]
    #        2013-11-11 19:40:00
            stock.change = !result[2].blank? ? result[2].to_f : 0.0
            stock.save
          else
            dead.push stock.symbol
          end          
          puts dead.count
          puts dead.inspect          
      end
      return true
    end



 
# Get current Option price from CBOE
  def self.option_price(symbol,strike,date,stock_option)
    require "net/http"
    require "uri"
    require 'rubygems'
    require 'mechanize'
    require 'json'
    require 'nokogiri'

    @agent = Mechanize.new 

# => 01/17/2015
     format_date =  date[8..9] + date[0..1] + date[3..4] 
     format_strike = "%08d" % ActionController::Base.helpers.number_with_precision(strike, precision: 3).to_s.split('.').join
     type = stock_option == 'Call Option' ? 'C' : 'P'     

     url = "https://finance.yahoo.com/quote/#{symbol.upcase}#{format_date}#{type}#{format_strike}/news?p=#{symbol.upcase}#{format_date}#{type}#{format_strike}"    
     puts url

     doc = ''
     ask = ''
      loop do 
        begin
          page = @agent.get(url)
        rescue Errno::ETIMEDOUT, Timeout::Error, Net::HTTPNotFound, Mechanize::ResponseCodeError
          puts '\n\n\nRetrying...\n\n\n'
          page = @agent.get(url)
        end  
        payload = page.body    

puts payload.length

        doc = Nokogiri::HTML(payload)
#        ask = doc.xpath('//td[@class="Ta(end) Fw(b)"]/text()')[3].to_s
        ask = doc.xpath('//td[@class="Ta(end) Fw(b) Lh(14px)"]')[3].to_s.split('data-reactid="55">').last.split('</span>').first.split('>').last.split('><').last.split('>').last
      break if !ask.empty?
      end
        
#        previous_close = doc.xpath('//td[@class="Ta(end) Fw(b)"]/text()')[0].to_s
#        bid = doc.xpath('//td[@class="Ta(end) Fw(b)"]/text()')[2].to_s
        previous_close = doc.xpath('//td[@class="Ta(end) Fw(b) Lh(14px)"]')[0].to_s.split('data-reactid="40">').last.split('</span>').first.split('>').last.split('><').last.split('>').last
        bid = doc.xpath('//td[@class="Ta(end) Fw(b) Lh(14px)"]')[2].to_s.split('data-reactid="50">').last.split('</span>').first.split('>').last
        time = doc.search("[text()*='EST']").first.to_s.split('">').last[5..-1].split('EST').first.strip
        date = Date.today.strftime("%Y/%m/%d")
        date = date + ' ' + time
                
        puts "bid: #{bid} ask: #{ask} prev: #{previous_close}"
              
        return { 'Time' => Time.parse(date).strftime("%Y/%m/%d %H:%M"), 'Bid' => bid, 'Ask' => ask, 'Previous_Close' => previous_close }
  end
  

# Refresh the Price List
  def self.refresh_all
    puts "Refresh Stocks\n\n"
    refresh_stocks
    puts "Refresh Options\n\n"
    refresh_options
    puts "Refresh Dividends\n\n"
    refresh_daily_dividend(Time.now.strftime("%Y-%m-%d"))
    return Price.all.count  
  end
    
  def self.refresh_options
    Price.all.each do |security|
      if security.sec_type != 'Stock'
        update = option_price(security.symbol, security.strike, security.exp_date, security.sec_type) 
        
        puts 'after return'
        
        security.last_update = update['Time']
        security.bid = update['Bid']
        security.ask = update['Ask']
        security.last_price = update['Previous_Close']
        security.save       
      end
    end
  end

#  def self.refresh_stocks
#    Price.where(:sec_type => 'Stock').each_slice(100) do |stocks|
#        list = stocks.collect { |s| s.symbol.downcase }
#          result = self.stock_price(list)
#        stocks.each do |stock|
#          
#          puts stock.symbol
#
##	puts stock.symbol.downcase.strip
##	puts list.inspect
#          
#          update = result.select { |s| s['Symbol'].downcase == stock.symbol.downcase.strip }[0]
#          stock.last_price = update['LastTrade'].to_f
#  #        stock.last_update = Time.parse(fields[3] + '/' + fields[1] + '/' + fields[2] + ' ' + update['LastTradeTime']).getutc
#  #        Mon, 11 Nov 2013 13:40:00 CST -06:00 
##          stock.last_update = fields[3] + '/' + fields[1] + '/' + fields[2] + ' ' + update['LastTradeTime']
#          stock.last_update = update['LastUpdate']
#  #        2013-11-11 19:40:00
#          stock.change = update['Change'].to_f
#          stock.save
#        end
#    end
#    return true
#  end
  
  
#  def self.latest_price(symbol, real_time)
#    valid = true
#    if real_time
#      price = MarketBeat.last_trade_real_time(symbol)
#      if price
#        price = price.to_f
#      else
#        valid = false
#      end
#      
#      datetime = MarketBeat.last_trade_datetime_real_time(symbol)
#      if datetime
#        month_day = datetime.split(',').first.split(' ')
#        month = "%02d" % Date::ABBR_MONTHNAMES.index(month_day.first)
#        day = month_day.last
#        format_date = Time.now.strftime('%Y') + '/' + month + '/' + day 
#        time = format_date + ' ' + datetime.last.split(' ').first
#      else
#        valid = false
#      end
#      
#      change = MarketBeat.change_real_time(symbol.upcase)
#    else
#      price = MarketBeat.last_trade(symbol.upcase).to_f
#      time = Time.now.strftime("%Y/%m/%d ") + MarketBeat.last_trade_time('aapl')
#      change = MarketBeat.change(symbol.upcase)
#    end 
#    return time, price, change, valid  
#  end

  def self.local_stock_price(symbol, real_time)    
    price = Price.where(:sec_type => 'Stock', :symbol => symbol.upcase )
    if price.empty? 
      latest = stock_price([symbol]).last
      #    ['Symbol', 'Name', 'LastTrade', 'LastTradeDate', 'LastTradeTime', 'Change' ]
      price = Price.create( :sec_type => 'Stock', :symbol => symbol.upcase,
                    :last_price => latest['LastTrade'], :last_update => latest['LastUpdate'],
                    :change => latest['Change'], :daily_dividend => 0 )
      return price.last_update.strftime("%H:%M%p %m/%d/%Y"), price.last_price, price.change, price.daily_dividend, price.daily_dividend_date
    else
      price = Price.where(:sec_type => 'Stock', :symbol => symbol.upcase ).first
      return price.last_update.strftime("%H:%M%p %m/%d/%Y"), price.last_price, price.change, price.daily_dividend, price.daily_dividend_date
    end
  end  



  def self.local_option_price(symbol, security_type, strike, expiration_date)
    option = Price.where( :sec_type => security_type, :symbol => symbol.upcase,
                          :strike => strike, :exp_date => expiration_date )
    if option.empty?
      latest = self.option_price(symbol, strike, expiration_date, security_type)
       new = Price.create( :sec_type => security_type, :symbol => symbol.upcase,
                           :strike => strike, :exp_date => expiration_date,
                           :last_update => latest['Time'], :bid => latest['Bid'],
                           :ask => latest['Ask'], :last_price => latest['Previous_Close'])
       option = [ new ]
    end
    price = option.first
    return price.last_update.strftime("%H:%M%p %m/%d/%Y"), price.bid, price.ask, price.last_price
  end  

  def self.valid_price?(price)
    price.to_s.match(/^[-+]?[0-9]*\.?[0-9]+$/)
  end
  
  def self.daily_snapshot # store in History record in DB
    refresh_all
    
#    puts 'Stocks and Options refresh complete - Hit key to continue'
#    city = gets.chomp
     
    refresh_daily_dividend( Time.now.strftime("%Y-%m-%d") ) # (Time.now - 1.day).strftime('%Y/%m/%d')  )
    
#    puts 'Daily Dividend collection complete - Hit key to continue'
#    city = gets.chomp
    
    Portfolio.all.each do |portfolio|
      hist = portfolio.histories.new
      
      puts portfolio.name
      
      stocks = portfolio.stocks.where(:stock_option => 'Stock')
        hist.stocks_count = stocks.count
        hist.stocks = stocks.reduce(0) { |sum, stock| sum + Price.where(symbol: stock.symbol, sec_type: 'Stock' )[0].last_price * stock.quantity }
        hist.daily_dividend = stocks.reduce(0) do |sum, stock| 
          puts "#{stock.symbol} - #{stock.quantity} - #{Price.where(symbol: 'GOOG', sec_type: 'Stock').first.daily_dividend}"
          sum + Price.where(symbol: 'GOOG', sec_type: 'Stock').first.daily_dividend * stock.quantity
        end
        hist.daily_dividend_date = Price.where(:sec_type => 'Stock').last.daily_dividend_date
      options = portfolio.stocks.where('stock_option != ?', 'Stock' )
        hist.options_count = options.count
        hist.options = options.reduce(0) do |sum,option| 
          
          puts option.symbol
          
          p = Price.where(:symbol => option.symbol, :sec_type => option.stock_option, :strike => option.strike, :exp_date => option.expiration_date ).first
          price = option.stock_option == 'Call Option' && option.quantity < 0 ? p.ask : p.bid 
          sum +  price * option.quantity * 100
        end
        hist.cash = portfolio.cash
        hist.total = hist.options + hist.stocks + hist.cash
        hist.snapshot_date = Time.now.beginning_of_day()
        hist.save
        
#        puts "Portfolio #{portfolio.name} complete - Hit key to continue"
#        city = gets.chomp
        
    end
  end
  
  def self.db_daily_snapshot # retrieve for display in graph
    arr = [ ]
    Portfolio.all.each do |port|
      sub_arr = [ ]
      port.histories.each do |hist|
        sub_arr.push [ hist.created_at.strftime('%m-%d-%Y') + ' 05:00PM', hist.total.to_s ]
      end
      arr.push sub_arr
    end
#    colors = [ '#4bb2c5', "#c5b47f", "#EAA228", "#579575", "#839557", "#958c12" ] 
#  	names = portfolios.collect { |u| User.find(u.user_id).name }
  	
    return arr   # , colors, names    
  end
  
  def self.daily_totals(start_date='07/01/2013', days=27, portfolios = [ 1, 2 ])
    all_lines = [ ]
    portfolios.count.times { all_lines.push [] }
    total_line = [ ]
    date = start_date.split('/')
    start = Time.new(date[2].to_i,date[0].to_i,date[1].to_i,0,0,0)

    (0..days).each do |day|
      day_values = History.where(:snapshot_date => start + day.days)      
      total_day = day_values.collect { |h| h.total }.inject(0) { |sum,tot| sum + tot }.to_i      
      if total_day != 0  
        total_line.push [ (start+day.days).strftime('%m-%d-%Y') + ' 05:00PM', total_day  ]
      else
        total_line.push [ (start+day.days).strftime('%m-%d-%Y') + ' 05:00PM', 'null'  ]        
      end
      portfolios.each_with_index do |port, idx|
        port_value = day_values.select { |hist| hist.portfolio_id == port }
        if !port_value.empty? 
          all_lines[idx].push [ (start+day.days).strftime('%m-%d-%Y') + ' 05:00PM', port_value.first.total.to_i ]
        else
          all_lines[idx].push [ (start+day.days).strftime('%m-%d-%Y') + ' 05:00PM', 'null' ]          
        end
      end        
    end
    
    return [ total_line, all_lines ]
  end
  
  def self.fix_date
    History.all.each do |hist|
      dates = hist.snapshot_date.strftime('%Y,%m,%d').split(',').collect { |val| val.to_i }
      y = dates[0]
      m = dates[1]
      d = dates[2]
      hist.snapshot_date = Time.new(y,m,d)
      hist.save
    end
  end
  
#History.where(:snapshot_date => '2013/07/25 22:00:00').collect { |hist| hist.total }.inject(0) { |result, element| result + element }.to_s
  
  def self.hist_dump
    list = [ ]
    History.all.each do |hist|
      list.push "#{hist.portfolio.name}, #{hist.snapshot_date}, #{hist.cash}, #{hist.stocks_count}, #{hist.stocks}, #{hist.options_count}, #{hist.options}, #{hist.total}"
    end
    list.each { |item| puts item }
    return nil
  end
  
  def self.get_annual(symbol)
    start_date = Date.new(2013, 01, 01)
    end_date = Date.today
    total = 0
    divs = [ ]
    begin
       resp = self.check_dividend(symbol, start_date.strftime("%Y-%m-%d") )
#       resp = self.check_dividend(symbol, start_date.strftime("%m/%d/%Y") )
       if resp['Date']
         total += resp[2]
         divs.push [resp['Date'], resp['Dividends']]
       end   
       start_date += 1.days
    end while start_date < end_date
    return total, divs
  end
  
  def self.refresh_daily_dividend(date)
      Price.all.each do |security|
        if security.sec_type == 'Stock'
#          today = (Time.now).strftime("%Y-%m-%d")
          div = check_dividend(security.symbol, date)
          security.daily_dividend = div[2] ||= 0
          security.daily_dividend_date = date
          puts div
         security.save
        end
      end
  end
  
  def self.check_dividend(symbol,date) # "2018-02-15"
    url = "https://api.iextrading.com/1.0/stock/#{symbol.upcase}/dividends/1m" 
    puts url
    # "paymentDate":"2018-02-15"
    # "amount":0.63
    @agent = Mechanize.new
    ret = [ symbol.upcase, date, nil ]
    dividends = 0
      begin
        page = @agent.get(url)
        response = page.body
        if response.length > 3 
          data = response
          data = JSON.parse data
          data.each do |d| 
            puts d
            paymentDate = d['paymentDate']
            if paymentDate == date
                dividends += d["amount"]
                puts dividends
            end
          end
           ret = [symbol.upcase, date, dividends]
        end
      rescue Errno::ETIMEDOUT, Timeout::Error, Net::HTTPNotFound, Mechanize::ResponseCodeError
        puts 'Unknown Reponse'
      end       
    puts ret.inspect
    puts 
    return ret
  end
  
#  def self.check_dividend(symbol,date)
#        comps = date.split('/')
#        year = comps[0]
#        month = comps[1]
#        day = comps[2]
#        ds = "&a=#{(month.to_i-1).to_s.rjust(2, '0')}&b=#{day.rjust(2, '0')}&c=#{year}&d=#{(month.to_i-1).to_s.rjust(2, '0')}&e=#{day.rjust(2, '0')}&f=#{year}"
#        url = "https://ichart.finance.yahoo.com/table.csv?s=#{symbol}#{ds}&g=v&ignore=.csv"
#        puts url
#        hp = { }
##          raw = open(url).read
##	  puts raw
##	  parsed = CSV.parse(raw)
##	  puts parsed
##          puts 'done'
#        begin            
#         resp = CSV.parse(open(url).read)          
#          if resp.length > 1 
#              str = resp[1][0].split('-')
#              hp['Date'] = str[1] + '/' + str[2] + '/' + str[0]
#            resp[0][1..-1].each_with_index do |title, i|
#              hp[title] = resp[1][i+1].to_f
#            end
#          end
#        rescue => e
#          hp['error'] = e.inspect
#        end              
#        return hp # hash with "Date", "Dividends"          
#  end
  
  
#  def self.daily_snapshot_test # store in History record in DB
#    
#    (1..1000).each do |index|
#      
#      (1..10).each { |i| puts '' }
#      (1..10).each { |i| puts index }
#      (1..10).each { |i| puts '' }
#      
#    
#    last_history = History.last.id
#    
#    puts 'Refreshing Prices'
#    refresh_all(true) # not realtime
#    
#    puts 'Refreshing Daily Dividend'
#    refresh_daily_dividend( (Time.now - 1.day).strftime('%Y/%m/%d')  )
#    
#    puts 'Creating Portfolio History Records'
#    Portfolio.all.each do |portfolio|
#      hist = portfolio.histories.new
#      stocks = portfolio.stocks.where(:stock_option => 'Stock')
#        hist.stocks_count = stocks.count
#        hist.stocks = stocks.reduce(0) { |sum, stock| sum + Price.find_by_symbol(stock.symbol).last_price * stock.quantity }
# 
#        hist.daily_dividend = stocks.reduce(0) { |sum, stock| sum + Price.find_by_symbol(stock.symbol).daily_dividend * stock.quantity }
#        hist.daily_dividend_date = Price.where(:sec_type => 'Stock').last.daily_dividend_date
#        puts "portfolio.name: Dividend: #{hist.daily_dividend} Date: #{hist.daily_dividend_date}"
# 
#      options = portfolio.stocks.where('stock_option != ?', 'Stock' )
#        hist.options_count = options.count
#        hist.options = options.reduce(0) do |sum,option| 
#          p = Price.where(:symbol => option.symbol, :sec_type => option.stock_option, :strike => option.strike, :exp_date => option.expiration_date ).first
#          price = option.stock_option == 'Call Option' && option.quantity < 0 ? p.ask : p.bid 
#          sum +  price * option.quantity * 100
#        end
#        hist.cash = portfolio.cash
#        hist.total = hist.options + hist.stocks + hist.cash
#        hist.snapshot_date = Time.now.beginning_of_day()
#        hist.save
#    end
#    puts "last history => #{last_history}, new last => #{History.last.id}"
#    History.where( 'id > :last_history and id <= :new_last', :last_history => last_history, :new_last => History.last.id).delete_all
#    
#  
#    end # outer loop counter
#    
#  end
  
#    def self.price_test
#      
#      (1..1000).each do |index|
#        
#        (1..10).each { |i| puts '' }
#        (1..10).each { |i| puts index }
#        (1..10).each { |i| puts '' }
#        
#          Price.all.each_with_index do |sec, index|
#               if sec.sec_type == 'Stock'
#  #               print "#{sec.id}: #{sec.symbol} "
#  #               price = MarketBeat.last_trade_real_time(sec.symbol.upcase).to_f
#  #               datetime = MarketBeat.last_trade_datetime_real_time(sec.symbol) # .split(',')
#  #               puts "#{price} at #{datetime}"
#  
#                 update = latest_price(sec.symbol, true)
#                 puts "#{sec.id}: #{sec.symbol} #{update.inspect}"
#               end
#          end
#      
#      end # outer loop counter
#                   
#    end
  
 
#    def self.dtegy
#
#      (1..1000).each do |index|
#
#                 update = latest_price('dtegy', true)
#                 puts "#{index}: #{update.inspect}"
#
#      end # outer loop counter
#
#    end


#  def self.quote_dtegy
#  
#    (1..1000).each do |index|
#  
#               update = stock_price(['dtegy'])
#               puts "#{index}: #{update.inspect}"
#  
#    end # outer loop counter
#  
#  end


end
