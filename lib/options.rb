# namespace :cboe do
#  task :options => :environment do

module Options
  require 'csv'
  require 'open-uri'
 
  def self.yp_test(n)
  	errors = []
  	stocks = Stock.where(stock_option: 'Fund').collect { |s| s.symbol }
  	for i in 0..n
  		stocks.each_with_index do |s, i|
  			puts s
  			if Options.yahoo_price(s).count != 4
  				errors.push s
  			end
  		end
  	puts errors.inspect
  	end
  end
  
  
  def self.yahoo_price(symbol)     
    @agent = Mechanize.new { |agent|
      agent.open_timeout   = 10
      agent.read_timeout   = 10
    }
    url = "http://finance.yahoo.com/quote/#{symbol}?p=#{symbol}"
    begin
      page = @agent.get(url)  
      doc = Nokogiri::HTML(page.body) 
      price = page.xpath('.//span[contains(@class,"Trsdu(0.3s) Fw(b)")]//text()')
      change = page.xpath('.//span[contains(@class,"Trsdu(0.3s) Fw(500)")]//text()') # Pstart(10px) Fz(24px)
    rescue Errno::ETIMEDOUT, Timeout::Error, Net::HTTPNotFound, Mechanize::ResponseCodeError
      puts "\n\nsymbol:#{symbol} - The request timed out...skipping.\n\n"
      puts Mechanize::ResponseCodeError
      puts "\n\n"
      return ["The request timed out...skipping."]
    rescue => e
      puts "\n\nsymbol:#{symbol} - The request returned an error - #{e.inspect}.\n\n"
      return ["The request returned an error - #{e.inspect}."]
    end     
    return [ symbol.upcase, price.to_s, change.to_s.split('(')[0], Time.now.to_s ] #.strftime("%Y/%m/%d %H:%M%p") ]       
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
        
        #puts data
        
        last_price = data['latestPrice'].to_s
        change = data["change"].to_s
        time = data["latestTime"]
        date = Time.parse(time) - 1.hour
        puts time
        
        ret = [symbol.upcase, last_price, change, Time.now.to_s ] #date.strftime("%Y/%m/%d %H:%M%p")]
      rescue Errno::ETIMEDOUT, Timeout::Error, Net::HTTPNotFound, Mechanize::ResponseCodeError
#        puts "#{symbol} - Unknown Response"
      end       
    return ret
  end 
    
 
# Get current Option price from yahoo
  def self.option_price(symbol,strike,date,stock_option)
    require "net/http"
    require "uri"
    require 'rubygems'
    require 'mechanize'
    require 'json'
    require 'nokogiri'

    @agent = Mechanize.new 
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
        doc = Nokogiri::HTML(payload)
#        ask = doc.xpath('//td[@class="Ta(end) Fw(b)"]/text()')[3].to_s
        ask = doc.xpath('//td[@class="Ta(end) Fw(b) Lh(14px)"]')[3].to_s.split('data-reactid="55">').last.split('</span>').first.split('>').last.split('><').last.split('>').last
      break if !ask.empty?
      end
        
#        previous_close = doc.xpath('//td[@class="Ta(end) Fw(b)"]/text()')[0].to_s
#        bid = doc.xpath('//td[@class="Ta(end) Fw(b)"]/text()')[2].to_s
        previous_close = doc.xpath('//td[@class="Ta(end) Fw(b) Lh(14px)"]')[0].to_s.split('data-reactid="40">').last.split('</span>').first.split('>').last.split('><').last.split('>').last
        bid = doc.xpath('//td[@class="Ta(end) Fw(b) Lh(14px)"]')[2].to_s.split('data-reactid="50">').last.split('</span>').first.split('>').last
        time = doc.search("[text()*='EDT']").first.to_s.split('">').last[5..-1].split('EST').first.strip
        date = Date.today.strftime("%Y/%m/%d")
        date = date + ' ' + time                
#        puts "bid: #{bid} ask: #{ask} prev: #{previous_close}"              
#        return { 'Time' => Time.parse(date).strftime("%Y/%m/%d %H:%M%p"), 'Bid' => bid, 'Ask' => ask, 'Previous_Close' => previous_close }
        return { 'Time' => Time.now.to_s, 'Bid' => bid, 'Ask' => ask, 'Previous_Close' => previous_close }
  end
  

    def self.get_dividends(symbol)
      url = "https://api.iextrading.com/1.0/stock/#{symbol.upcase}/dividends/1y" 
      @agent = Mechanize.new
      data = {}
        begin
          page = @agent.get(url)
          response = page.body
          data = JSON.parse(response).collect { |d| [ d['exDate'], d['amount'] ] }
        rescue Errno::ETIMEDOUT, Timeout::Error, Net::HTTPNotFound, Mechanize::ResponseCodeError
        end       
      return data
    end

  def self.yahoo_dividends(symbol)  
      #  https://finance.yahoo.com/quote/SPY/history?period1=1494651600&period2=1526187600&interval=div%7Csplit&filter=div&frequency=1mo
      period1 = (Time.now-1.year).to_i
      period2 = (Time.now).to_i
      interval = "div%7Csplit" # "div|split"
      filter = "div"
      frequency = "1mo"

      url = "https://finance.yahoo.com/quote/#{symbol}/history?period1=#{period1}&period2=#{period2}&interval=#{interval}" +
            "&filter=#{filter}&frequency=#{frequency}" 
            
      @agent = Mechanize.new 
#            loop do 
              begin
                page = @agent.get(url)
              rescue Errno::ETIMEDOUT, Timeout::Error, Net::HTTPNotFound, Mechanize::ResponseCodeError
                puts '\n\n\nRetrying...\n\n\n'
                page = @agent.get(url)
              end  
              payload = page.body    
              doc = Nokogiri::HTML(payload)
      #        ask = doc.xpath('//td[@class="Ta(end) Fw(b)"]/text()')[3].to_s
                dates = []
                doc.xpath('//table[@class="W(100%) M(0)"]//tr//td//span').collect { |d| d }.each do |date|
                  begin
                     d = Date.parse(date.to_s.split('>').last.split('<').first).to_s
                     dates.push(d)
                  rescue
                  end
                end
                amounts = []
                doc.xpath('//table[@class="W(100%) M(0)"]//tr//td//strong').each do |amount|
                  begin
                    v = amount.to_s.split('>').last.split('<').first
                     amounts.push(v.to_f)
                  rescue
                  end
                end
            divs = [ ]    
            dates.each_with_index do |d,i|
             divs.push [ d, amounts[i] ]
            end
            return divs
      
  end



end
