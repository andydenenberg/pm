namespace :update do
 
 
  desc 'Daily GRAT Snapshot'
      task :daily_GRAT_snapshot => :environment do

        options = [ [ 'AMAT', '01/21/2022', 12800, 42.28, 57.5, 65 ],
                    [ 'CRM', '01/21/2022', 24000, 134.31, 180.0, 210.0 ],
                    [ 'CSCO', '01/21/2022', 63000, 39.06, 42.5, 47.5 ],
                    [ 'INTC', '01/21/2022', 15365, 54.13, 60.0, 65.0 ],
                    [ 'MSFT', '01/21/2022', 12110, 153.83, 190.0, 220.0 ] ]
              
        output = "Start\n"
        output += "#{Time.now.strftime("%m/%d %H:%M")}\n"
        output += "Symbol, Quantity, Basis, Current Price, Change Price, Current Value, Change Value, Put Strike, Put Bid, Put Ask, Call Strike, Call Bid, Call Ask\n"
                
        options.each do |o|
          symbol = o[0]
          exp_date = o[1]
          quant = o[2]
          basis = o[3]
          put_strike = o[4]
          call_strike = o[5]
          current_info = Options.repo_price(o[0])
      #    current_info = Options.yahoo_price(o[0])
          current_price = current_info[1].to_f
          current_gain = quant * (current_price - o[3])

          put_option = Options.option_price(symbol, put_strike, exp_date, 'Put Option')
          call_option = Options.option_price(symbol, call_strike, exp_date, 'Call Option')
  
          output += "#{symbol}, #{quant}, #{basis}, #{current_price}, #{current_info[2]}, #{quant.to_d*current_price.to_d}, #{quant.to_d*current_info[2].to_d}, #{put_strike}, #{put_option['Bid']}, #{put_option['Ask']}, #{call_strike}, #{call_option['Bid']}, #{call_option['Ask']}\n" 
        end  
  
        output += "End<br>"
        
        require 'sendgrid-ruby'
        include SendGrid
        
        body = output
        
        puts body

        from = Email.new(email: 'winnetkadrone@gmail.com')
        subject = "#{ENV["APP_NAME"]} GRATS Daily Snapshot"
        to = Email.new(email: 'andy@denenberg.net')
        content = Content.new(type: 'text/html', value: body)
        
#        mail = SendGrid::Mail.new(from, subject, to, content)
#        sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
#        response = sg.client.mail._('send').post(request_body: mail.to_json)
        
      end

  
desc "Grats protection"
  task :gprotect => :environment do

    options = [ [ 'AMAT', '01/21/2022', 12800, 42.28, 57.5, 65 ],
                [ 'CRM', '01/21/2022', 24000, 134.31, 180.0, 210.0 ],
                [ 'CSCO', '01/21/2022', 63000, 39.06, 42.5, 47.5 ],
                [ 'INTC', '01/21/2022', 15365, 54.13, 60.0, 65.0 ],
                [ 'MSFT', '01/21/2022', 12110, 153.83, 190.0, 220.0 ] ]
              
  gain_total = 0 
  gain_change_total = 0           
  max_total = 0
  min_total = 0
  cost_total = 0
  
  puts Time.now
              
  options.each do |o|
    symbol = o[0]
    exp_date = o[1]
    quant = o[2]
    basis = o[3]
    put_strike = o[4]
    call_strike = o[5]
    current_info = Options.repo_price(o[0])
#    current_info = Options.yahoo_price(o[0])
    current_price = current_info[1].to_f
    current_gain = quant * (current_price - o[3])
    gain_total += current_gain
    gain_change = quant * current_info[2].to_f
    gain_change_total += gain_change

    cost = Options.option_price(symbol, put_strike, exp_date, 'Put Option')['Ask'].to_f
    min_band = 100 * (current_price - put_strike) / put_strike
    sale = Options.option_price(symbol, call_strike, exp_date, 'Call Option')['Bid'].to_f
    max_band = 100 * (call_strike - current_price) / call_strike

    total_cost = sale - cost
    min_gain = quant * (put_strike - basis + total_cost)
    min_total += min_gain
    max_gain = quant * (call_strike - basis + total_cost) 
    max_total += max_gain
    cost_total += quant * total_cost   
  
    puts "
    #{ActionController::Base.helpers.number_with_precision(quant, :precision => 0, :delimiter => ',')} of #{symbol} Price: #{ActiveSupport::NumberHelper.number_to_currency(current_price)} (#{current_info[2]})     
    Gain: $#{ActionController::Base.helpers.number_with_precision(current_gain, :precision => 2, :delimiter => ',')} ($#{ActionController::Base.helpers.number_with_precision(gain_change, :precision => 2, :delimiter => ',')})
    Basis: #{ActiveSupport::NumberHelper.number_to_currency(basis)} (#{ActionController::Base.helpers.number_with_precision(100*(current_price-basis)/basis, :precision => 2, :delimiter => ',')}% Gain)
    Put: $#{put_strike} Cost: $#{cost} Band: #{ActionController::Base.helpers.number_with_precision(min_band, :precision => 2, :delimiter => ',')}% Min: #{ActiveSupport::NumberHelper.number_to_currency(min_gain)}
    Call: $#{call_strike} Sale: $#{sale} Band: #{ActionController::Base.helpers.number_with_precision(max_band, :precision => 2, :delimiter => ',')}% Max: #{ActiveSupport::NumberHelper.number_to_currency(max_gain)}
    Net Cost: #{ActiveSupport::NumberHelper.number_to_currency(total_cost*quant)} is #{ActionController::Base.helpers.number_with_precision( 100 * (total_cost*quant) / current_gain, :precision => 2, :delimiter => ',')}% of unadjusted gain
    Adjusted Gain: $#{ActionController::Base.helpers.number_with_precision(current_gain + (total_cost*quant), :precision => 2, :delimiter => ',')}"
      
  end  
  
  puts "
  Gain Total: #{ActiveSupport::NumberHelper.number_to_currency(gain_total)} (#{ActiveSupport::NumberHelper.number_to_currency(gain_change_total)})
  Min Total: #{ActiveSupport::NumberHelper.number_to_currency(min_total)}
  Max Total: #{ActiveSupport::NumberHelper.number_to_currency(max_total)}
  Cost Total: #{ActiveSupport::NumberHelper.number_to_currency(cost_total)}
  Adjusted Total: #{ActiveSupport::NumberHelper.number_to_currency(gain_total + cost_total)}"

end 


desc "Grats Value"
  task :grats => :environment do
    stocks = [ [12800, 'AMAT', 541184 ], [24000, 'CRM', 3223440 ], [ 63000, 'CSCO', 2460780 ], [ 15365, 'INTC', 831707 ], [ 12110, 'MSFT', 1862881 ] ]
    initial_total = 8919992
    current_total = 0
    current_change = 0
    prices = [ ]
    stocks.each do |s|
      value = Options.repo_price(s[1])
#      value = Options.yahoo_price(s[1])
      current_value = (s[0] * value[1].to_f)
      prices.push value[1]
      current_total += current_value
      daily_change = (s[0] * value[2].to_f)
      current_change += daily_change
      puts "#{s[1]} 
      #{value[1]} #{value[2]}
      #{ ActiveSupport::NumberHelper.number_to_currency( current_value ) }
      #{ ActiveSupport::NumberHelper.number_to_currency( daily_change ) }"
    end
    puts "Total:
    #{ActiveSupport::NumberHelper.number_to_currency(current_total - initial_total) }
    #{ActiveSupport::NumberHelper.number_to_currency(current_change) }"
    puts
    puts prices
  end
 
  desc "Update single portfolio"
    task :update_portfolio => :environment do
      require 'csv'

      file = '/Users/andydenenberg/Downloads/latest.CSV'
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

portfolio_id = 7

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
        "portfolio_id: p.id, " +  # #{portfolio_id}, " +
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
