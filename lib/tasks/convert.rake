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
                "convert:portfolios", "convert:create_groups", "convert:populate_groups",
                "convert:stocks", "convert:options", 
                "convert:check_for_funds", "convert:refresh_all",
                "convert:upload_history", "history:all_ports" ]

  desc 'Create Portfolios'
# Portfolio.all.collect { |i| i.cash.to_f }
  portfolios = ["ETrade", "SLAT1", "SLAT2", "A&R", "DHC", "MSA", "River North", "R", "A Roth IRA", "A 401K Rollover", "R 401K Rollover", "R Roth IRA", "HSA", "BAD Inherited Roth", "GRATS 2015"]
  cash = [63654.11, 1189041.0, 666362.57, 44875.91, 671063.84, 220911.51, 513802.0, 21034.79, 46141.03, 99309.92, 108924.47, 25651.99, 3800.0, 5043.44, 0.0]
    task :portfolios => :environment do
      portfolios.each_with_index do |p, i|
        Portfolio.create!( :id => i+3, :name => p, :cash => cash[i], group_id: 1 )
      end 
      puts "Portfolios Created"     
    end

  desc 'Create Portfolio Groups'
    task :create_groups => :environment do
      ['Personel Portfolios', "All SLATs", "Retirement Portfolios"].each do |name|
        Group.create! ( { name: name } )
      end 
      puts "Portfolios Groups Created"     
    end

  desc 'Populate Portfolio Groups'
    group_ids = [ ["ETrade", 1], ["SLAT1", 2], ["SLAT2", 2], ["A&R", 1], ["DHC", 1], ["MSA", 1], ["River North", 1], ["R", 1], 
                  ["A Roth IRA", 3], ["A 401K Rollover", 3], ["R 401K Rollover", 3], ["R Roth IRA", 3], ["HSA", 3], ["BAD Inherited Roth", 3], ["GRATS 2015", 1 ] ]
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
          stocks = [["R", "K", 300.0, "Stock"], ["R", "HPQ", 88.0, "Stock"], ["ETrade", "PGF", 1500.0, "Stock"], ["MSA", "AAPL", 840.0, "Stock"], ["MSA", "CSCO", 13300.0, "Stock"], ["MSA", "CSCO", 800.0, "Stock"], ["MSA", "CVS", 690.0, "Stock"], ["MSA", "GS", 80.0, "Stock"], ["MSA", "MCD", 260.0, "Stock"], ["MSA", "MO", 300.0, "Stock"], ["MSA", "MSFT", 7153.0, "Stock"], ["MSA", "NKE", 1000.0, "Stock"], ["MSA", "PFE", 290.0, "Stock"], ["MSA", "PM", 340.0, "Stock"], ["MSA", "STT", 377.0, "Stock"], ["MSA", "SYK", 2130.0, "Stock"], ["MSA", "UTX", 400.0, "Stock"], ["MSA", "WBA", 840.0, "Stock"], ["MSA", "XOM", 500.0, "Stock"], ["MSA", "ZBRA", 750.0, "Stock"], ["ETrade", "CSCO", 200.0, "Stock"], ["ETrade", "INTC", 500.0, "Stock"], ["ETrade", "MSFT", 200.0, "Stock"], ["ETrade", "RWX", 200.0, "Stock"], ["HSA", "MGRIX", 272.84, "Stock"], ["HSA", "TGVAX", 180.78, "Stock"], ["HSA", "PEOPX", 185.34, "Stock"], ["HSA", "GGSAX", 216.1, "Stock"], ["HSA", "VSMAX", 75.4, "Stock"], ["HSA", "VIMAX", 27.44, "Stock"], ["R", "VITSX", 152.64, "Stock"], ["R", "DODFX", 148.48, "Stock"], ["ETrade", "QLD", 800.0, "Stock"], ["ETrade", "EWG", 300.0, "Stock"], ["ETrade", "BTI", 45.0, "Stock"], ["R", "HPE", 88.0, "Stock"], ["R", "DXC", 7.0, "Stock"], ["GRATS 2015", "AMAT", 5326.0, "Stock"], ["GRATS 2015", "CRM", 1973.0, "Stock"], ["GRATS 2015", "INTC", 1545.0, "Stock"], ["GRATS 2015", "MSFT", 2007.0, "Stock"], ["GRATS 2015", "CSCO", 5272.0, "Stock"], ["A&R", "ABB", 1000.0, "Stock"], ["A&R", "ABBV", 500.0, "Stock"], ["A&R", "ACN", 300.0, "Stock"], ["A&R", "ASIX", 24.0, "Stock"], ["A&R", "AFL", 700.0, "Stock"], ["A&R", "GOOGL", 100.0, "Stock"], ["A&R", "MO", 46.0, "Stock"], ["A&R", "AMGN", 400.0, "Stock"], ["A&R", "AAPL", 151.0, "Stock"], ["A&R", "BA", 200.0, "Stock"], ["A&R", "CAT", 300.0, "Stock"], ["A&R", "CSCO", 2016.0, "Stock"], ["A&R", "KO", 1000.0, "Stock"], ["A&R", "DTEGY", 3500.0, "Stock"], ["A&R", "DISH", 500.0, "Stock"], ["A&R", "EBAY", 500.0, "Stock"], ["A&R", "EMR", 400.0, "Stock"], ["A&R", "XOM", 18.0, "Stock"], ["A&R", "GBDC", 1000.0, "Stock"], ["A&R", "HON", 600.0, "Stock"], ["A&R", "INTC", 3425.0, "Stock"], ["A&R", "KSU", 300.0, "Stock"], ["A&R", "MCD", 411.0, "Stock"], ["A&R", "MSFT", 1030.0, "Stock"], ["A&R", "NOK", 5.0, "Stock"], ["A&R", "PYPL", 500.0, "Stock"], ["A&R", "PFE", 5.0, "Stock"], ["A&R", "PM", 6.0, "Stock"], ["A&R", "PPG", 400.0, "Stock"], ["A&R", "STT", 1.0, "Stock"], ["A&R", "TEL", 500.0, "Stock"], ["A&R", "USB", 1000.0, "Stock"], ["A&R", "UNH", 400.0, "Stock"], ["A&R", "VZ", 1000.0, "Stock"], ["A&R", "V", 600.0, "Stock"], ["A&R", "WBA", 1500.0, "Stock"], ["A&R", "WMT", 300.0, "Stock"], ["A&R", "WFC", 1000.0, "Stock"], ["A&R", "EWH", 2000.0, "Stock"], ["A&R", "QLD", 4000.0, "Stock"], ["A&R", "SPY", 600.0, "Stock"], ["A&R", "MOAT", 1000.0, "Stock"], ["A&R", "VGK", 700.0, "Stock"], ["A&R", "DXJ", 500.0, "Stock"], ["A 401K Rollover", "AAPL", 1050.0, "Stock"], ["A 401K Rollover", "DISH", 500.0, "Stock"], ["A 401K Rollover", "GE", 1000.0, "Stock"], ["A 401K Rollover", "GIS", 100.0, "Stock"], ["A 401K Rollover", "INTC", 250.0, "Stock"], ["A 401K Rollover", "STX", 200.0, "Stock"], ["A 401K Rollover", "TOT", 500.0, "Stock"], ["A 401K Rollover", "UPS", 150.0, "Stock"], ["A 401K Rollover", "WFC", 500.0, "Stock"], ["A 401K Rollover", "BIF", 6242.0, "Stock"], ["A 401K Rollover", "LQD", 100.0, "Stock"], ["A 401K Rollover", "QLD", 1600.0, "Stock"], ["A 401K Rollover", "MOAT", 750.0, "Stock"], ["A Roth IRA", "ACN", 100.0, "Stock"], ["A Roth IRA", "A", 152.0, "Stock"], ["A Roth IRA", "AMZN", 10.0, "Stock"], ["A Roth IRA", "AXP", 300.0, "Stock"], ["A Roth IRA", "AMP", 60.0, "Stock"], ["A Roth IRA", "AAPL", 280.0, "Stock"], ["A Roth IRA", "CSCO", 2160.0, "Stock"], ["A Roth IRA", "CNDT", 200.0, "Stock"], ["A Roth IRA", "DXC", 68.0, "Stock"], ["A Roth IRA", "HPE", 800.0, "Stock"], ["A Roth IRA", "HPQ", 800.0, "Stock"], ["A Roth IRA", "IBM", 180.0, "Stock"], ["A Roth IRA", "KEYS", 76.0, "Stock"], ["A Roth IRA", "MFGP", 109.0, "Stock"], ["A Roth IRA", "ORCL", 375.0, "Stock"], ["A Roth IRA", "VOD", 250.0, "Stock"], ["A Roth IRA", "XRX", 250.0, "Stock"], ["A Roth IRA", "XLI", 300.0, "Stock"], ["A Roth IRA", "SPY", 100.0, "Stock"], ["A Roth IRA", "VWO", 300.0, "Stock"], ["BAD Inherited Roth", "T", 118.0, "Stock"], ["BAD Inherited Roth", "ABBV", 155.0, "Stock"], ["BAD Inherited Roth", "ACN", 90.0, "Stock"], ["BAD Inherited Roth", "ADI", 117.0, "Stock"], ["BAD Inherited Roth", "AAPL", 236.0, "Stock"], ["BAD Inherited Roth", "ARMK", 50.0, "Stock"], ["BAD Inherited Roth", "CSCO", 318.0, "Stock"], ["BAD Inherited Roth", "CLX", 84.0, "Stock"], ["BAD Inherited Roth", "CL", 118.0, "Stock"], ["BAD Inherited Roth", "COP", 147.0, "Stock"], ["BAD Inherited Roth", "CSX", 304.0, "Stock"], ["BAD Inherited Roth", "CMI", 58.0, "Stock"], ["BAD Inherited Roth", "DRI", 142.0, "Stock"], ["BAD Inherited Roth", "ETN", 115.0, "Stock"], ["BAD Inherited Roth", "FNB", 368.0, "Stock"], ["BAD Inherited Roth", "FCPT", 64.0, "Stock"], ["BAD Inherited Roth", "ITW", 105.0, "Stock"], ["BAD Inherited Roth", "INTC", 227.0, "Stock"], ["BAD Inherited Roth", "IVZ", 217.0, "Stock"], ["BAD Inherited Roth", "JNJ", 90.0, "Stock"], ["BAD Inherited Roth", "KMB", 40.0, "Stock"], ["BAD Inherited Roth", "KMI", 143.0, "Stock"], ["BAD Inherited Roth", "MCD", 91.0, "Stock"], ["BAD Inherited Roth", "MRK", 161.0, "Stock"], ["BAD Inherited Roth", "MCHP", 193.0, "Stock"], ["BAD Inherited Roth", "MSFT", 237.0, "Stock"], ["BAD Inherited Roth", "OKE", 54.0, "Stock"], ["BAD Inherited Roth", "PEP", 92.0, "Stock"], ["BAD Inherited Roth", "PFE", 242.0, "Stock"], ["BAD Inherited Roth", "PG", 88.0, "Stock"], ["BAD Inherited Roth", "SBUX", 66.0, "Stock"], ["BAD Inherited Roth", "UMPQ", 513.0, "Stock"], ["BAD Inherited Roth", "UNH", 95.0, "Stock"], ["BAD Inherited Roth", "WM", 183.0, "Stock"], ["BAD Inherited Roth", "WFC", 190.0, "Stock"], ["BAD Inherited Roth", "SBHSX", 366.7, "Stock"], ["BAD Inherited Roth", "SBHVX", 315.66, "Stock"], ["DHC", "MMM", 300.0, "Stock"], ["DHC", "ABT", 1000.0, "Stock"], ["DHC", "ABBV", 1000.0, "Stock"], ["DHC", "ASIX", 40.0, "Stock"], ["DHC", "APD", 300.0, "Stock"], ["DHC", "GOOGL", 100.0, "Stock"], ["DHC", "AMGN", 6000.0, "Stock"], ["DHC", "AAPL", 4900.0, "Stock"], ["DHC", "BHF", 90.0, "Stock"], ["DHC", "COF", 750.0, "Stock"], ["DHC", "SNP", 1807.0, "Stock"], ["DHC", "CSCO", 2000.0, "Stock"], ["DHC", "CMCSA", 1000.0, "Stock"], ["DHC", "HON", 1000.0, "Stock"], ["DHC", "INTC", 2000.0, "Stock"], ["DHC", "JNJ", 600.0, "Stock"], ["DHC", "MET", 1000.0, "Stock"], ["DHC", "MSFT", 1000.0, "Stock"], ["DHC", "PFE", 1000.0, "Stock"], ["DHC", "PPG", 400.0, "Stock"], ["DHC", "SIEGY", 600.0, "Stock"], ["DHC", "SBUX", 1000.0, "Stock"], ["DHC", "UNP", 400.0, "Stock"], ["DHC", "UPS", 800.0, "Stock"], ["DHC", "UTX", 300.0, "Stock"], ["DHC", "VSM", 150.0, "Stock"], ["DHC", "WBA", 1000.0, "Stock"], ["DHC", "WFC", 3000.0, "Stock"], ["DHC", "LQD", 1350.0, "Stock"], ["DHC", "PRF", 300.0, "Stock"], ["DHC", "QQQ", 500.0, "Stock"], ["DHC", "QLD", 4000.0, "Stock"], ["DHC", "SPY", 500.0, "Stock"], ["DHC", "VINEX", 3298.58, "Stock"], ["R 401K Rollover", "ABT", 200.0, "Stock"], ["R 401K Rollover", "ABBV", 200.0, "Stock"], ["R 401K Rollover", "ASIX", 8.0, "Stock"], ["R 401K Rollover", "GOOG", 30.0, "Stock"], ["R 401K Rollover", "AXP", 200.0, "Stock"], ["R 401K Rollover", "AMGN", 100.0, "Stock"], ["R 401K Rollover", "AAPL", 1400.0, "Stock"], ["R 401K Rollover", "BA", 400.0, "Stock"], ["R 401K Rollover", "BWA", 800.0, "Stock"], ["R 401K Rollover", "BP", 100.0, "Stock"], ["R 401K Rollover", "CVX", 150.0, "Stock"], ["R 401K Rollover", "CSCO", 300.0, "Stock"], ["R 401K Rollover", "CL", 400.0, "Stock"], ["R 401K Rollover", "COP", 200.0, "Stock"], ["R 401K Rollover", "COST", 120.0, "Stock"], ["R 401K Rollover", "DXC", 25.0, "Stock"], ["R 401K Rollover", "FB", 250.0, "Stock"], ["R 401K Rollover", "FLS", 300.0, "Stock"], ["R 401K Rollover", "FCX", 400.0, "Stock"], ["R 401K Rollover", "GE", 1000.0, "Stock"], ["R 401K Rollover", "GS", 100.0, "Stock"], ["R 401K Rollover", "HYH", 37.0, "Stock"], ["R 401K Rollover", "HPE", 300.0, "Stock"], ["R 401K Rollover", "HON", 200.0, "Stock"], ["R 401K Rollover", "HPQ", 300.0, "Stock"], ["R 401K Rollover", "JPM", 500.0, "Stock"], ["R 401K Rollover", "KMB", 300.0, "Stock"], ["R 401K Rollover", "MCD", 200.0, "Stock"], ["R 401K Rollover", "MFGP", 41.0, "Stock"], ["R 401K Rollover", "NBR", 500.0, "Stock"], ["R 401K Rollover", "PFE", 1500.0, "Stock"], ["R 401K Rollover", "PSX", 100.0, "Stock"], ["R 401K Rollover", "SLB", 250.0, "Stock"], ["R 401K Rollover", "STX", 200.0, "Stock"], ["R 401K Rollover", "SBUX", 800.0, "Stock"], ["R 401K Rollover", "TOT", 300.0, "Stock"], ["R 401K Rollover", "RIG", 300.0, "Stock"], ["R 401K Rollover", "UTX", 200.0, "Stock"], ["R 401K Rollover", "EFA", 200.0, "Stock"], ["R 401K Rollover", "QQQ", 30.0, "Stock"], ["R 401K Rollover", "QLD", 1600.0, "Stock"], ["R 401K Rollover", "SPY", 100.0, "Stock"], ["R 401K Rollover", "EZM", 300.0, "Stock"], ["R 401K Rollover", "GOODX", 309.57, "Stock"], ["R Roth IRA", "AAPL", 140.0, "Stock"], ["R Roth IRA", "IVV", 100.0, "Stock"], ["R Roth IRA", "EFA", 258.0, "Stock"], ["R Roth IRA", "DVY", 130.0, "Stock"], ["R Roth IRA", "QLD", 248.0, "Stock"], ["R Roth IRA", "VWO", 300.0, "Stock"], ["R Roth IRA", "EZM", 300.0, "Stock"], ["SLAT1", "MMM", 300.0, "Stock"], ["SLAT1", "A", 555.0, "Stock"], ["SLAT1", "APD", 900.0, "Stock"], ["SLAT1", "GOOGL", 100.0, "Stock"], ["SLAT1", "AMGN", 300.0, "Stock"], ["SLAT1", "AAPL", 140.0, "Stock"], ["SLAT1", "AMAT", 552.0, "Stock"], ["SLAT1", "ADSK", 1900.0, "Stock"], ["SLAT1", "CCL", 900.0, "Stock"], ["SLAT1", "CTL", 1012.0, "Stock"], ["SLAT1", "CB", 1674.0, "Stock"], ["SLAT1", "CSCO", 22000.0, "Stock"], ["SLAT1", "KO", 3735.0, "Stock"], ["SLAT1", "CVS", 1800.0, "Stock"], ["SLAT1", "DXC", 154.0, "Stock"], ["SLAT1", "DE", 200.0, "Stock"], ["SLAT1", "DLR", 1308.0, "Stock"], ["SLAT1", "DWDP", 450.0, "Stock"], ["SLAT1", "ETN", 1080.0, "Stock"], ["SLAT1", "GD", 1188.0, "Stock"], ["SLAT1", "GEF", 800.0, "Stock"], ["SLAT1", "HPE", 1800.0, "Stock"], ["SLAT1", "HRL", 1600.0, "Stock"], ["SLAT1", "HPQ", 1800.0, "Stock"], ["SLAT1", "INTC", 8000.0, "Stock"], ["SLAT1", "JNJ", 400.0, "Stock"], ["SLAT1", "K", 400.0, "Stock"], ["SLAT1", "KEYS", 277.0, "Stock"], ["SLAT1", "MCD", 1970.0, "Stock"], ["SLAT1", "MDT", 1100.0, "Stock"], ["SLAT1", "MFGP", 247.0, "Stock"], ["SLAT1", "MSFT", 17080.0, "Stock"], ["SLAT1", "MON", 900.0, "Stock"], ["SLAT1", "NKE", 5400.0, "Stock"], ["SLAT1", "PH", 300.0, "Stock"], ["SLAT1", "PEP", 891.0, "Stock"], ["SLAT1", "PFE", 2982.0, "Stock"], ["SLAT1", "PM", 900.0, "Stock"], ["SLAT1", "PG", 780.0, "Stock"], ["SLAT1", "SBUX", 1000.0, "Stock"], ["SLAT1", "UPS", 810.0, "Stock"], ["SLAT1", "UTX", 1476.0, "Stock"], ["SLAT1", "VZ", 1496.0, "Stock"], ["SLAT1", "VSM", 450.0, "Stock"], ["SLAT1", "V", 1800.0, "Stock"], ["SLAT1", "WBA", 4800.0, "Stock"], ["SLAT1", "DIS", 1200.0, "Stock"], ["SLAT1", "WFC", 1000.0, "Stock"], ["SLAT1", "LQD", 940.0, "Stock"], ["SLAT1", "EFA", 9050.0, "Stock"], ["SLAT1", "IWM", 500.0, "Stock"], ["SLAT1", "PGF", 21800.0, "Stock"], ["SLAT1", "QLD", 2000.0, "Stock"], ["SLAT2", "MMM", 180.0, "Stock"], ["SLAT2", "T", 900.0, "Stock"], ["SLAT2", "ASIX", 18.0, "Stock"], ["SLAT2", "GOOGL", 100.0, "Stock"], ["SLAT2", "MO", 1440.0, "Stock"], ["SLAT2", "AAPL", 5600.0, "Stock"], ["SLAT2", "ADM", 1044.0, "Stock"], ["SLAT2", "AGR", 630.0, "Stock"], ["SLAT2", "BMO", 360.0, "Stock"], ["SLAT2", "BA", 500.0, "Stock"], ["SLAT2", "BWA", 1260.0, "Stock"], ["SLAT2", "BG", 450.0, "Stock"], ["SLAT2", "COF", 360.0, "Stock"], ["SLAT2", "CSCO", 6250.0, "Stock"], ["SLAT2", "CMCSA", 1260.0, "Stock"], ["SLAT2", "CSX", 540.0, "Stock"], ["SLAT2", "DEO", 450.0, "Stock"], ["SLAT2", "DLR", 588.0, "Stock"], ["SLAT2", "DWDP", 720.0, "Stock"], ["SLAT2", "EGP", 450.0, "Stock"], ["SLAT2", "FLS", 405.0, "Stock"], ["SLAT2", "GS", 450.0, "Stock"], ["SLAT2", "HYH", 78.0, "Stock"], ["SLAT2", "HIG", 360.0, "Stock"], ["SLAT2", "HON", 450.0, "Stock"], ["SLAT2", "HUM", 270.0, "Stock"], ["SLAT2", "INTC", 1800.0, "Stock"], ["SLAT2", "JNJ", 720.0, "Stock"], ["SLAT2", "JPM", 810.0, "Stock"], ["SLAT2", "KMB", 630.0, "Stock"], ["SLAT2", "MNK", 112.0, "Stock"], ["SLAT2", "MDT", 860.0, "Stock"], ["SLAT2", "MRK", 1170.0, "Stock"], ["SLAT2", "NVS", 360.0, "Stock"], ["SLAT2", "ORCL", 900.0, "Stock"], ["SLAT2", "PH", 360.0, "Stock"], ["SLAT2", "PAYX", 4266.0, "Stock"], ["SLAT2", "PSX", 720.0, "Stock"], ["SLAT2", "PPG", 600.0, "Stock"], ["SLAT2", "PX", 450.0, "Stock"], ["SLAT2", "QCOM", 270.0, "Stock"], ["SLAT2", "SBUX", 720.0, "Stock"], ["SLAT2", "TOT", 180.0, "Stock"], ["SLAT2", "DIS", 900.0, "Stock"], ["SLAT2", "EWH", 1800.0, "Stock"], ["SLAT2", "EWT", 675.0, "Stock"]]
          puts stocks.count
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
        options = [["DHC", "AMGN", -10.0, "Call Option", 200.0, "06/15/2018"], ["DHC", "AMGN", -10.0, "Call Option", 210.0, "06/15/2018"], ["DHC", "CELG", 10.0, "Call Option", 120.0, "01/18/2019"], ["SLAT1", "MSFT", -10.0, "Call Option", 95.0, "06/15/2018"], ["SLAT1", "MSFT", -10.0, "Call Option", 97.5, "07/20/2018"]]  
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