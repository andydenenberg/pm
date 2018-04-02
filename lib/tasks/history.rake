namespace :history do
    
  desc 'Upload History'
      task :upload => :environment do
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

