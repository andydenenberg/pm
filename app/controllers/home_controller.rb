class HomeController < ApplicationController
  def index
    @portfolios = Portfolio.all.collect { |p| p.name }
    @portfolios.unshift "All Portfolios"

    period = "Last Year"
    results = History.graph_data('All Portfolios', period)
#    @dates = results[0]
#    @colors = results[1]
    @values = results[0]
    @time = results[1]
    
    @name = 'All Portfolios'
    
    puts @values.inspect
    
  end
    
  def refresh
    portfolio = params[:portfolio]
    period = params[:period]
    
    period = "Last Year"
    
    results = History.graph_data(portfolio, period)
    
    @values = results[0]
    @name = portfolio    
      
 #     system "rake convert:refresh RAILS_ENV=#{Rails.env}" #  --trace >> #{Rails.root}/log/rake.log &"

      respond_to do |format|
          format.js
      end
  end
  
  
end
