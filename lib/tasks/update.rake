namespace :update do

  desc "Update single portfolio"
    task :update_portfolio => :environment do
      require 'csv'

      file = '/Users/andydenenberg/Downloads/FTMLLC.CSV'
#      file = '/Users/andydenenberg/Desktop/Hellemb_A/May_2018/R 401K Rollover.CSV'
      portfolio_name = File.basename(file).split('.').first   

  # first find and delete old stocks
  #      stocks = portfolio.stocks
  #      puts "#{stocks.count} stocks found and deleted"
  #      stocks.delete_all

  # then add the new stocks    
      stocks = CSV.read(file)  # Andy.CSV')
      stock_total = stocks[3..-3].inject(0) { |result, element| result + element[6].gsub('$','').gsub(',','').to_f }
      cash = stocks[-2][6].gsub('$','').gsub(',','').to_f
      if Portfolio.where(:name => portfolio_name).empty?
        portfolio =  "Portfolio.create!( name: '#{portfolio_name}', cash: #{cash}, group_id: 1 )\n"
        portfolio_id = '?'
      else
        portfolio = "p = Portfolio.where(:name => '#{portfolio_name}').first\n"
        portfolio += "p.cash = #{cash}\n"
        portfolio += "p.save\n"
        portfolio_id = Portfolio.where(:name => portfolio_name).first.id
      end
      puts
      puts portfolio
      puts
      
      port_stocks = ''
      stocks[3..-3].each do |s|
        symbol = s[0]

        strike = nil
        expiration_date = nil
        quantity = s[2].gsub(',','').to_f
        purchase_price = s[9].gsub('$','').gsub(',','').to_f / quantity

        case s[15]
        when 'Equity'
          stock_option = 'Stock'
        when 'Option'
          stock_option = s[1][0..15].include?('CALL') ? 'Call Option' : 'Put Option'
          #        BIDU 06/19/2015 210.00 C
                   option = s[0].split(' ')
                   strike = option[2].to_f
                   symbol = option[0]
                   expiration_date = option[1]
        when 'Fixed Income'
          stock_option = 'Fixed Income'
        when 'ETFs & Closed End Funds'
          stock_option = 'Fund'
        else
          stock_option = 'Fund'
        end

        port_stocks +=
        "Stock.create!(" +
        "symbol: '#{symbol}', " +
        "name: '#{s[1][0..15]}', " +
        "quantity: #{quantity}, " +
        "daily_dividend: 0, " +
        "price: 0, " +
        "change: 0, " +
        "as_of: '2018/04/26 23:00PM', " +
        "purchase_price: #{purchase_price}, " +
        "portfolio_id: #{portfolio_id}, " +
        "stock_option: '#{stock_option}', " +
        "strike: #{strike.inspect}, " +
        "expiration_date: #{expiration_date.inspect})\n"

        end # stocks

        puts port_stocks

      end # update_portfolio




desc "Update Portfolios"
  task :update_holdings => :environment do
    require 'csv'

    base_dir = '/Users/andydenenberg/Desktop/Hellemb_B/heraga'
    files = Dir["#{base_dir}/*"]
  
# find the portfolios
# the histories are linked to the portfolio id's so don't delete Portfolios, just stocks
    portfolios = [ ]
        
    files.each do |file|
      portfolio = File.basename(file).split('.').first   # Portfolio.where(:name => File.basename(file).split('.').first).first
      if portfolio
        portfolios.push( [ portfolio, file ] )
      end
    end
    
    new_portfolios = ''
    portfolio_id = 1
# for each portfolio
    portfolios.each do |portfolio, file|
 
# first find and delete old stocks
#      stocks = portfolio.stocks
#      puts "#{stocks.count} stocks found and deleted"
#      stocks.delete_all
      
# then add the new stocks    
    stocks = CSV.read(file)  # Andy.CSV')
    stock_total = stocks[3..-3].inject(0) { |result, element| result + element[6].gsub('$','').gsub(',','').to_f }
    cash = stocks[-2][6].gsub('$','').gsub(',','').to_f
    new_portfolios +=  "Portfolio.create!( id: #{portfolio_id}, name: '#{portfolio}', cash: #{cash}, group_id: 1 )\n"
        
    port_stocks = ''
    puts portfolio
    stocks[3..-3].each do |s|
      symbol = s[0]

      strike = nil
      expiration_date = nil
      quantity = s[2].gsub(',','').to_f
      purchase_price = s[9].gsub('$','').gsub(',','').to_f / quantity
      
      case s[15]
      when 'Equity'
        stock_option = 'Stock'
      when 'Option'
        stock_option = s[1][0..15].include?('CALL') ? 'Call Option' : 'Put Option'
        #        BIDU 06/19/2015 210.00 C
                 option = s[0].split(' ')
                 strike = option[2].to_f
                 symbol = option[0]
                 expiration_date = option[1]
      when 'Fixed Income'
        stock_option = 'Fixed Income'
      when 'ETFs & Closed End Funds'
        stock_option = 'Fund'
      else
        stock_option = 'Fund'
      end
       
       
       
       
#       ["VTKLF", "BRKB", "NSRGY", "RHHBY", "BRKB"]
       
       
      port_stocks +=
      "Stock.create!(" +
      "symbol: '#{symbol}', " +
      "name: '#{s[1][0..15]}', " +
      "quantity: #{quantity}, " +
      "daily_dividend: 0, " +
      "price: 0, " +
      "change: 0, " +
      "as_of: '2018/04/26 23:00PM', " +
      "purchase_price: #{purchase_price}, " +
      "portfolio_id: #{portfolio_id}, " +
      "stock_option: '#{stock_option}', " +
      "strike: #{strike.inspect}, " +
      "expiration_date: #{expiration_date.inspect})\n"

      end # stocks
      
      puts port_stocks
      puts
      portfolio_id += 1
            
    end # portfolios
        
    puts
    puts new_portfolios
    
    end # update_holdings


  desc 'Create Portfolios'
# Portfolio.all.collect { |i| i.cash.to_f }
  portfolios = ["ETrade", "SLAT1", "SLAT2", "A&R", "DHC", "MSA", "River North", "R", "A Roth IRA", "A 401K Rollover", "R 401K Rollover", "R Roth IRA", "HSA", "BAD Inherited Roth", "GRATS 2015"]
  cash = [63654.11, 1189041.0, 666362.57, 44875.91, 671063.84, 220911.51, 513802.0, 21034.79, 46141.03, 99309.92, 108924.47, 25651.99, 3800.0, 5043.44, 0.0]
    task :portfolios => :environment do
      portfolios.each_with_index do |p, i|
        Portfolio.create!( :id => i+3, :name => p, :cash => cash[i] )
      end 
      puts "Portfolios Created"     
    end

    desc 'Create Stocks'
        task :stocks => :environment do
          # Stock.where(:stock_option => 'Stock').collect { |s| [ s.portfolio.name, s.symbol, s.quantity.to_f, s.stock_option ] }
          stocks = ['MMM', '3M COMPANY', 355.0, 156.2, 1, 'Stock', nil, nil, '12/31/2012' ]
          puts stocks.count
      stocks.each do |s|
        s = Stock.create!( daily_dividend: 0, symbol => s[0], :name => s[1], :quantity => s[2], :purchase_price => s[3], :portfolio_id => s[4], :stock_option => s[5] )
      end  
      puts "Stock Created"     
    end

end # update
