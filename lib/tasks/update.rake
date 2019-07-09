namespace :update do

# 
  desc "Update single portfolio"
    task :update_portfolio => :environment do
      require 'csv'

#      file = '/Users/andydenenberg/Downloads/Fir Tree Mountain LLC.CSV'
#      file = '/Users/andydenenberg/Downloads/Marital Trust SBH.CSV'
      file = '/Users/andydenenberg/Downloads/A&R.CSV'
      portfolio_name = File.basename(file).split('.').first.gsub('_',' ')
      
      puts portfolio_name
      
  # first find and delete old stocks
  #      stocks = portfolio.stocks
  #      puts "#{stocks.count} stocks found and deleted"
  #      stocks.delete_all

  # then add the new stocks    
      stocks = CSV.read(file)  # Andy.CSV')
      stock_total = stocks[3..-3].inject(0) { |result, element| result + element[6].gsub('$','').gsub(',','').to_f }
      cash = stocks[-2][6].gsub('$','').gsub(',','').to_f
#      if Portfolio.where(:name => portfolio_name).empty?
#        portfolio =  "Portfolio.create!( name: '#{portfolio_name}', cash: #{cash}, group_id: 1 )\n"
#      else
        portfolio = "p = Portfolio.where(:name => '#{portfolio_name}').first\n"
        portfolio += "p.cash = #{cash}\n"
        portfolio += "p.save\n"

portfolio_ids = { } 
# run the following in Heroku and place result in-line below
Portfolio.all.each { |p| puts "portfolio_ids['#{p.name}'] = #{p.id}" }
        
      portfolio_id = portfolio_ids[portfolio_name] # Portfolio.where(:name => portfolio_name).first.id

portfolio_id = 6

#      end
      puts
      puts portfolio
      puts 'p.stocks.delete_all'
      puts portfolio_name
      puts portfolio_id
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
          stock_option = 'Fund' # as of 06/15/2019 started using yahoo quotes exclusively
#          stock_option = 'Stock'
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
        puts 
        puts
        puts

      end # update_portfolio




desc "Update Portfolios"
  task :update_holdings => :environment do
    require 'csv'

    base_dir = '??'
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



end # update
