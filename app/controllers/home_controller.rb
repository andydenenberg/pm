class HomeController < ApplicationController
  
  def info
        #render :layout => false   
  end
  
  def index
    @portfolios = ["All Portfolios"] + Group.all.collect { |group| group.name } + Portfolio.all.collect { |p| p.name }    
    @periods = ['from Start', 'Last 3 Years', 'Last 2 Years', 'Year to Date', 'Month to Date']
    
    @period = params[:period] ||= "Last 2 Years"
    @portfolio = params[:portfolio] ||= 'All Portfolios'    
    
    results = History.graph_data(@portfolio, @period)
    @values = results[0]
    
    scale = Lib.graph_scale(@values)
    
    puts scale
    
    @max = scale[0]
    @min = scale[1]
    @step = scale[2]
    
    @values = results[0].to_s.gsub(" 0,"," ,").gsub("[0,","[ ").gsub("0]"," ]")    
    @time = results[1]
    @year = results[2].to_s
    @name = @portfolio

    respond_to do |format|
        format.html
        format.js
    end
    
  end
  
  private

    def pad_with_zeros(value)
      value = value.split(/(?=(?:...)*$)/)
      padded = [value[0]]
      (value.count-1).times { |b| padded += ['000'] }
      padded = padded.join
      return padded
    end
  
  
end
