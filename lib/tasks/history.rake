namespace :history do
   
    desc 'Daily Snapshot'
        task :daily_snapshot => :environment do
          totals = History.daily_snapshot
          
          require 'sendgrid-ruby'
          include SendGrid
          body = "Finished at: #{Time.now.strftime("%m/%d %H:%M")}<br>Value: $#{ActiveSupport::NumberHelper.number_to_delimited(totals[0].round)}<br>Change: $#{ActiveSupport::NumberHelper.number_to_delimited(totals[1].round)}<br>"

          from = Email.new(email: 'winnetkadrone@gmail.com')
          subject = "#{ENV["APP_NAME"]} Daily Snapshot complete"
          to = Email.new(email: 'andy@denenberg.net')
          content = Content.new(type: 'text/html', value: body)
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

