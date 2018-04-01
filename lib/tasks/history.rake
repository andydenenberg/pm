namespace :history do
    
  desc 'Upload History'
      task :upload => :environment do
        url = "https://s3.us-east-2.amazonaws.com/her-history/history.json" 
        @agent = Mechanize.new
            page = @agent.get(url)
            data = JSON.parse(page.body) 
        puts data.count
        puts data.last
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
