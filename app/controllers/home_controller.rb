class HomeController < ApplicationController
  def index
    @portfolios = Portfolio.all.collect { |p| p.name }
    @portfolios.unshift "All Portfolios"
    @periods = ['from Start', 'Year to Date', 'Last Year', 'Month to Date']
    
    @period = params[:period] ||= "from Start"
    @portfolio = params[:portfolio] ||= 'All Portfolios'
    
    results = History.graph_data(@portfolio, @period)
    @values = results[0]
    @max = (@values.max * 1.1).to_s.length
    @min = @values.min * 0.9    
    @values = results[0].to_s.gsub(" 0,"," ,").gsub("[0,","[ ").gsub("0]"," ]")    
    @time = results[1]
    @year = results[2].to_s
    @name = @portfolio

    respond_to do |format|
        format.html
        format.js
    end
    
  end
  
  
end
