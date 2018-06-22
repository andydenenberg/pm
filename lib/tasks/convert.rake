namespace :convert do

# heroku drop db
# heroku pg:reset DATABASE

desc 'Reset PG Indexes'
task :reset_pg_index => :environment do
  
  # heroku pg:reset DATABASE_URL

    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end
end
  

desc 'Build the Databases'
task :setup => ["db:migrate", 
                "convert:create_groups", "convert:portfolios", "convert:populate_groups",
                "convert:stocks", "convert:options", 
                "convert:check_for_funds", "convert:refresh_all"]
                # "convert:upload_history", "history:all_ports" ]

  desc 'Create Portfolios'
# Portfolio.all.collect { |i| i.cash.to_f }
  portfolios = ["Portfolio1"]
  cash = [1000.00]
    task :portfolios => :environment do
      portfolios.each_with_index do |p, i|
        Portfolio.create!( :id => i+3, :name => p, :cash => cash[i], group_id: 1 )
      end 
      puts "Portfolios Created"     
    end

  desc 'Create Portfolio Groups'
    task :create_groups => :environment do
      ['Personel Portfolios'].each do |name|
        Group.create! ( { name: name } )
      end 
      puts "Portfolios Groups Created"     
    end

  desc 'Populate Portfolio Groups'
    group_ids = [ ["Portfolio1", 1] ]
    task :populate_groups => :environment do
      group_ids.each do |p|
        port = Portfolio.find_by_name(p[0])
        port.group_id = p[1]
        port.save
      end 
      puts "Portfolios Groups Created"     
    end
    
    
  desc 'Create Stocks'
      task :stocks => :environment do
        # Stock.where(:stock_option => 'Stock').collect { |s| [ s.portfolio.name, s.symbol, s.quantity.to_f, s.stock_option ] }
          stocks = [["Portfolio1", "K", 300.0, "Stock"], ["Portfolio1", "HPQ", 88.0, "Stock"] ]
      stocks.each do |s|
        s = Stock.create!( :portfolio_id => Portfolio.find_by_name(s[0]).id, :symbol => s[1], :quantity => s[2], :stock_option => s[3], )
      end  
      puts "Stock Created"     
    end

  desc 'Create Options'
      task :options => :environment do
        # Rails 3
        # Stock.where(stock_option: ['Call Option', 'Put Option'] ).collect { |s| [ s.portfolio.name, s.symbol, s.quantity.to_f, s.stock_option, s.strike.to_f, s.expiration_date ] }
        # Rails 5
        # Stock.where(:stock_option => 'Call Option').or(Stock.where(:stock_option => 'Call Option')).collect { |s| [ s.portfolio.name, s.symbol, s.quantity.to_f, s.stock_option ] }
        options = [["Portfolio1", "AMGN", -10.0, "Call Option", 200.0, "06/15/2018"]]  
      options.each do |s|
        puts s
        puts s[0]
        puts Portfolio.find_by_name(s[0])
        s = Stock.create!( :portfolio_id => Portfolio.find_by_name(s[0]).id, :symbol => s[1],
                           :quantity => s[2], :stock_option => s[3], :strike => s[4], :expiration_date => s[5] )
      end 
      puts "Options Created"          
    end

    desc 'Refresh on Request'
      task :refresh_on_request => :environment do
        
        @ironcache = IronCache::Client.new
        @cache = @ironcache.cache("my_cache")
        state = @cache.get("poll_request").value
        if  state == 'Waiting' || state == 'Updating'
          @cache.put("poll_request", 'Complete')
          Stock.refresh_all('Stock')
          Stock.refresh_all('Option')
          Stock.refresh_all('Fund')
#          @cache.put("poll_request", 'Complete')
          @cache.put("poll_request_time", Time.now.to_s)
        end 
        
      end

    desc 'Refresh All Prices'
      task :refresh_all => :environment do
        Stock.refresh_all('Stock')
        Stock.refresh_all('Option')
        Stock.refresh_all('Fund')
        puts "Prices Refreshed"     
      end
      
    desc 'Check for Funds'
      task :check_for_funds => :environment do
        Stock.check_all_for_funds    
        puts "Funds converted"     
      end
    
#   desc 'Upload History'
#   #   target = open('history.json', 'w')
#   #   target.write(History.all.to_json)
#   #   target.close
#       task :upload_history => :environment do
#         url = "https://s3.us-east-2.amazonaws.com/her-history/history.json" 
#         @agent = Mechanize.new
#           page = @agent.get(url)
#           data = JSON.parse(page.body) 
#           data.each do |h|
#             puts h.inspect
#             h = History.create!(h) 
#           end
#       end
        

    
end