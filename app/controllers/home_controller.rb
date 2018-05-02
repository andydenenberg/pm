class HomeController < ApplicationController
  
  def info   
  end
  
  def index
    @portfolios = ["All Portfolios"] + Group.all.collect { |group| group.name } + Portfolio.all.collect { |p| p.name }    
    @periods = ['from Start', 'Last 3 Years', 'Last 2 Years', 'Year to Date', 'Month to Date']
    
    @period = params[:period] ||= "Last 2 Years"
    @portfolio = params[:portfolio] ||= 'All Portfolios'    
    
    results = History.graph_data(@portfolio, @period)
    @values = results[0]
    
    max = (@values.max * 1.05).round.to_s
    puts 'max: ' + max
    @max = pad_with_zeros(max)
    puts @max
    
    min_vals = @values.reject {|x| x == 0 }
    puts
    puts min_vals.min
    min = (min_vals.min * 0.95).round.to_s
    puts 'min: ' + min
    @min = pad_with_zeros(min)
    puts @min
      
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
