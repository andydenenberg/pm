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
    
      
    if @values.max > 10000000
      @max = (@values.max.to_s[0..1].to_i + 2).to_s + '000000'
      puts 'max: ' + @max
      min_vals = @values.reject {|x| x == 0 }.min # throw out negatives
      min = (min_vals * 0.9).round.to_s
      puts 'min: ' + min
      @min = pad_with_zeros(min)
      @step = '2000000'
    elsif @values.max > 5000000 
      @max = (@values.max.to_s[0..1].to_i + 5).to_s + '00000'
      puts 'max: ' + @max
      min_vals = @values.reject {|x| x == 0 }.min # throw out negatives
      min = (min_vals * 0.9).round.to_s
      puts 'min: ' + min
      @min = pad_with_zeros(min)
      @step = '500000'
    elsif @values.max > 1000000 
      @max = (@values.max.to_s[0..1].to_i + 5).to_s + '00000'
      puts 'max: ' + @max
      min_vals = @values.reject {|x| x == 0 }.min # throw out negatives
      min = (min_vals * 0.9).round.to_s
      puts 'min: ' + min
      @min = pad_with_zeros(min)
      @step = '250000'
    else 
      @max = (@values.max.to_s[0..1].to_i + 5).to_s + '0000'
      puts 'max: ' + @max
      min_vals = @values.reject {|x| x == 0 }.min # throw out negatives
      min = (min_vals * 0.9).round.to_s
      puts 'min: ' + min
      @min = pad_with_zeros(min)
      @step = '10000'
    end 
    puts 'step: ' + @step
    
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
