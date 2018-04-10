class HomeController < ApplicationController
  def index
    @portfolios = Portfolio.all.collect { |p| p.name }
    @portfolios.unshift "All Portfolios"
    @periods = ['from Start', 'Year to Date', 'Last Year', 'Month to Date']
    
    period = "from Start"

    results = History.graph_data('All Portfolios', period)
    @values = results[0]
    @max = (@values.max * 1.1).to_s.length
    @min = @values.min * 0.9
    
    @values = results[0].to_s.gsub(" 0,"," ,").gsub("[0,","[ ").gsub("0]"," ]")
    @time = results[1]
    
    @name = 'All Portfolios'
    
    puts @values.inspect
    
  end

  def update_prices
    system "rake convert:refresh RAILS_ENV=#{Rails.env}" #  --trace >> #{Rails.root}/log/rake.log &"
    respond_to do |format|
        format.js
    end
  end
  
  def refresh
    portfolio = params[:portfolio]
    @period = params[:period]
    results = History.graph_data(portfolio, @period)
    
    @values = results[0]
    @max = (@values.max * 1.1).to_s.length
    @min = @values.min * 0.9
    @values = @values.to_s.gsub(" 0,"," ,").gsub("[0,","[ ").gsub("0]"," ]")
    @time = results[1]
    @name = portfolio 
    
    respond_to do |format|
        format.js
    end
  end
  
  
end
