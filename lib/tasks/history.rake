namespace :history do
   
#  # Translation Table at 626 
#  # [["ETrade", 3], ["SLAT1", 4], ["SLAT2", 5], ["A&R", 6], ["DHC", 7], ["MSA", 8], ["River North", 9], ["R", 10], ["A Roth IRA", 11], ["A 401K Rollover", 12], ["R 401K Rollover", 13], ["R Roth IRA", 14], ["HSA", 15], ["BAD Inherited Roth", 16], ["GRATS 2015", 17]] 
#  # on Heroku
#  # [["ETrade", 1], ["SLAT1", 2], ["SLAT2", 3], ["A&R", 4], ["DHC", 5], ["MSA", 6], ["River North", 7], ["R", 8], ["A Roth IRA", 9], ["A 401K Rollover", 10], ["R 401K Rollover", 11], ["R Roth IRA", 12], ["HSA", 13], ["BAD Inherited Roth", 14], ["GRATS 2015", 15]]
#  home_ids = [["ETrade", 3], ["SLAT1", 4], ["SLAT2", 5], ["A&R", 6], ["DHC", 7], ["MSA", 8], ["River North", 9], ["R", 10], ["A Roth IRA", 11], ["A 401K Rollover", 12], ["R 401K Rollover", 13], ["R Roth IRA", 14], ["HSA", 15], ["BAD Inherited Roth", 16], ["GRATS 2015", 17]] 
#  heroku_ids = [["ETrade", 1], ["SLAT1", 2], ["SLAT2", 3], ["A&R", 4], ["DHC", 5], ["MSA", 6], ["River North", 7], ["R", 8], ["A Roth IRA", 9], ["A 401K Rollover", 10], ["R 401K Rollover", 11], ["R Roth IRA", 12], ["HSA", 13], ["BAD Inherited Roth", 14], ["GRATS 2015", 15]]  
#  home_ids.each_with_index do |home, index|
#    h = History.where(:portfolio_id => home )
#    h.each do |n|
#      n.portfolio_id = heroku_ids[index][1]
#      puts heroku_ids[index][0] + ' = ' + home_ids[index][0]
#      n.save
#    end
#  end 

    #    all_dates = History.by_month("January", year: 2017).distinct.pluck(:snapshot_date)

    desc 'Daily Snapshot'
        task :daily_snapshot => :environment do
#          History.daily_snapshot
          
          require 'sendgrid-ruby'
          include SendGrid

          body = "Finished at: #{Time.now}"

          from = Email.new(email: 'her17@denfam.com')
          subject = 'Her17 Daily Snapshot complete'
          to = Email.new(email: 'andy@denenberg.net')
          content = Content.new(type: 'text/plain', value: 'finished')
          mail = SendGrid::Mail.new(from, subject, to, content)

          sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
          response = sg.client.mail._('send').post(request_body: mail.to_json)
          
        end
 
    desc 'Create All Portfolios History'
      task :all_ports => :environment do

        portfolio_id = 9999  # the all portfolios record

        all_dates = History.all.distinct.pluck(:snapshot_date)
        all_dates.each do |date|
          total_cash = History.where(:snapshot_date => date.beginning_of_day..date.end_of_day).sum { |h| h.cash } 
          total_stocks = History.where(:snapshot_date => date.beginning_of_day..date.end_of_day).sum { |h| h.stocks }
          total_stocks_count = History.where(:snapshot_date => date.beginning_of_day..date.end_of_day).sum { |h| h.stocks_count } 
          total_options = History.where(:snapshot_date => date.beginning_of_day..date.end_of_day).sum { |h| h.options }
          total_options_count = History.where(:snapshot_date => date.beginning_of_day..date.end_of_day).sum { |h| h.options_count } 
          total_daily_dividend = History.where(:snapshot_date => date.beginning_of_day..date.end_of_day).sum { |h| h.daily_dividend || 0 }                  
          total_all = History.where(:snapshot_date => date.beginning_of_day..date.end_of_day).sum { |h| h.total }
          h = History.create ( { portfolio_id: portfolio_id, cash: total_cash, snapshot_date: date,
                                 stocks: total_stocks, stocks_count: total_stocks_count, 
                                 options: total_options, options_count: total_options_count,
                                 daily_dividend: total_daily_dividend, daily_dividend_date: date,
                                 total: total_all } )
#          STDIN.gets 
#          History.create! (cash: total_cash, stocks: total_stocks, stocks_count: total_stocks_count, options: total_options,
#                           daily_dividend: total_daily_dividend, total: total_all )
        end
        puts "All History created"     
      end

  
  
  desc 'Upload History'
  #   target = open('history.json', 'w')
  #   target.write(History.all.to_json)
  #   target.close
      task :upload_history => :environment do
        url = "https://s3.us-east-2.amazonaws.com/her-history/history.json" 
        @agent = Mechanize.new
          page = @agent.get(url)
          data = JSON.parse(page.body) 
          data.each do |h|
            puts h.inspect
            h = History.create!(h) 
          end
      end
  end
          #   target = open('history.json', 'w')
          #   target.write(History.all.to_json)
          #   target.close
          #   
          #   h = open 'history.json'
          #   JSON.parse(h.read)
          #   
          #   History.all.collect { |h| [ s.portfolio.name, s.symbol, s.quantity.to_f, s.stock_option ] }
#History.limit(10).collect { |s| [ s.portfolio.name, s.symbol, s.quantity.to_f, s.stock_option ] }

# rails g scaffold History cash:decimal stocks:decimal stocks_count:integer options:decimal options_count:decimal total:decimal snapshot_date:datetime portfolio_id:integer daily_dividend:decimal daily_dividend_date:datetime

