class HomeController < ApplicationController

  helper_method :sort_column, :sort_direction

  def system_config
    s = Sysconfig.first
    @min = s.ytd_min ||= 500000
    @max = s.ytd_max ||= 1000000
  end
  def system_config_save
    @max = params[:max]
    @min = params[:min]    
    s = Sysconfig.first
    s.ytd_max = params[:max]
    s.ytd_min = params[:min]
    s.save
    render 'system_config'
  end
  
  def highlights_modal
    @port_gl = params[:port_gl]
    case @port_gl
      when 'port'
      portfolio = Portfolio.find_by_name(params[:portfolio_name])
      @portfolio_name = portfolio.name
      table_data = Stock.table_data(@portfolio_name, sort_column, sort_direction)    
      @stocks = table_data[0]
      @options = Stock.where(portfolio_id: portfolio.id, stock_option: ['Call Option', 'Put Option']).order('quantity DESC')
      @cash = portfolio.cash
      @total_options_value = portfolio.total_options_value
      @total_stocks_value = portfolio.total_stocks_value
      @total_stocks_change = portfolio.total_stocks_change_value
      render 'home/highlights/highlights_portfolio'
    when 'gl'
      @stocks = Stock.where(symbol: params[:symbol], stock_option: ['Stock', 'Fund']).order('quantity DESC')
      @options = Stock.where(symbol: params[:symbol], stock_option: ['Call Option', 'Put Option']).order('quantity DESC')
      render 'home/highlights/highlights_stock'
    else
      @portfolio_name = 'All Portfolios'
      table_data = Stock.table_data(@portfolio_name, sort_column, sort_direction)    
      @stocks = table_data[0]
      @total_value = table_data[2]
      @total_change = table_data[3]
      
#      @stocks = Stock.where(stock_option: ['Stock', 'Fund']).order('symbol ASC')
      @options = Stock.where(stock_option: ['Call Option', 'Put Option']).order('quantity DESC')
      @cash = Portfolio.all.sum(0) { |p| p.cash }
      @total_options_value = Portfolio.all.sum { |p| p.total_options_value }
      @total_stocks_value = Portfolio.all.sum { |p| p.total_stocks_value }
      @total_stocks_change = Portfolio.all.sum { |p| p.total_stocks_change_value }
      render 'home/highlights/highlights_portfolio'
    end
    
  end
  
  def chart_comparison
    data = [ ]
    Portfolio.find([5,6,7]).each do |p|
      start_year_total = History.where(portfolio_id: p.id, snapshot_date: Date.today.beginning_of_year..Date.today.beginning_of_year+2).first.total
#      start_month_total = History.where(portfolio_id: p.id, snapshot_date: Date.today.beginning_of_month..Date.today.beginning_of_month+2).first.total
      series = History.where(portfolio_id: p.id, snapshot_date: Date.today.beginning_of_year..Date.today).collect { |h| [ h.snapshot_date.strftime("%-m/%-d"), (h.total / start_year_total).to_f ]  }      
      data.push ( { name: p.name, data: series } ) 
    end 
    render json: data
  end

  def highlights

    reload_update
    
    @portfolios_data = Portfolio.table_data(nil, 1)  
    @winners = Stock.table_data('All Portfolios', 'change', 'asc')[0]
    @loosers = @winners.sort { |x,y| x[3] <=> y[3] } # sort by daiy change in value
     #Stock.table_data('All Portfolios', 'change', 'desc')[0]
    @dividends = Dividend.order('date desc')
    
    stock_divs = Stock.calc_dividends('All Portfolios', ['Stock','Fund']) 
    @month_to_date_divs = stock_divs[-1].first
    @year_to_date_divs = stock_divs[-1][0..Date.today.month-1].sum
    
    s = Sysconfig.first
    @min = s.ytd_min ||= 500000
    @max = s.ytd_max ||= 1000000
    
    @start_totals = [ ]
    Portfolio.all.each do |p|
      start_year_total = History.where(portfolio_id: p.id, snapshot_date: Date.today.beginning_of_year..Date.today.beginning_of_year+2).first.total
      start_month_total = History.where(portfolio_id: p.id, snapshot_date: Date.today.beginning_of_month..Date.today.beginning_of_month+2).first.total
      total = p.total_stocks_value+p.cash
      day_change = p.total_stocks_change_value
      month_change = total - start_month_total
      year_change = total - start_year_total       
      @start_totals.push [ p.name, total.to_f, start_month_total.to_f, start_year_total.to_f, day_change.to_f, month_change.to_f, year_change.to_f ]
    end 
      @start_totals.sort { |x,y| x[6] <=> y[6] } # sort by daiy change in value
    
    respond_to do |format|
        format.html 
    end    
  end
  
  def poll_check
    ironcache = IronCache::Client.new
    cache = ironcache.cache("my_cache")
    @poll_request_time = cache.get("poll_request_time").value
    @data = Hash.new
    @data['poll_request'] = cache.get("poll_request").value
      respond_to do |format|
          format.js
      end
  end
  
  def poll_set
      if ENV['RACK_ENV'] != 'development'      
#        system "rake convert:refresh_all" run on Heroku      
       @ironcache = IronCache::Client.new
       @cache = @ironcache.cache("my_cache")
       state = @cache.get("poll_request").value
       if state == 'Idle' || state == 'Complete'
         @cache.put("poll_request", 'Waiting')
       end
      end     
  end
  
  def consolidated

    reload_update
    
    @sort_by = params[:sort_by].to_i ||= 1
    @perspectives = [ 'Consolidated', 'Positions', 'Graphs', 'Dividends' ]
    @perspective = params[:perspective] ||= 'Consolidated'
    @portfolios = ["All Portfolios"] + Group.all.collect { |group| group.name } #+ Portfolio.all.collect { |p| p.name }    
    if Group.find_by_name(params[:portfolio_name])
      @portfolio_name = params[:portfolio_name]
      group_id = Group.find_by_name(@portfolio_name).id
    else 
      @portfolio_name = 'All Portfolios'
      group_id = nil
    end

    @portfolios_data = Portfolio.table_data(group_id, @sort_by)  

    respond_to do |format|
        format.html  #{ render :layout => false }   
        format.js { render :layout => false, :template => "home/consolidated" }  
    end    
  end
  
  def positions
    @perspectives = [ 'Consolidated', 'Positions', 'Graphs', 'Dividends' ]
    @perspective = params[:perspective] ||= 'Positions'
    @portfolio_name = params[:portfolio_name] ||= 'All Portfolios'
    @individual = params[:individual]

    @portfolios = ["All Portfolios"] + Group.all.collect { |group| group.name } + Portfolio.all.collect { |p| p.name }    
    table_data = Stock.table_data(@portfolio_name, sort_column, sort_direction)    
    @stocks = table_data[0]
    @dividends = table_data[1]
    @total_value = table_data[2]
    @total_change = table_data[3]
    
    respond_to do |format|
        format.html
        format.js { render :layout => false, :template => "home/positions" }  
    end       
  end
  
  def graphs
    @perspective = params[:perspective] ||= 'Graphs'
    @portfolio_name = params[:portfolio_name] ||= 'All Portfolios'
  
    @portfolios = ["All Portfolios"] + Group.all.collect { |group| group.name } + Portfolio.all.collect { |p| p.name }    
    @periods = ['from Start', 'Last 3 Years', 'Last 2 Years', 'Year to Date', 'Month to Date']

    @period = params[:period] ||= "Last 2 Years"

    results = History.graph_data(@portfolio_name, @period)
    @values = results[0]

    scale = Lib.graph_scale(@values)

    @max = scale[0]
    @min = scale[1]
    @step = scale[2]

    @values = results[0].to_s.gsub(" 0,"," ,").gsub("[0,","[ ").gsub("0]"," ]")    
    @time = results[1]
    @year = results[2].to_s
    @name = @portfolio

    respond_to do |format|
        format.html
        format.js { render :layout => false, :template => "home/graphs" }  
    end       
    
  end

  def dividends 
    @perspective = params[:perspective] ||= 'Dividends'    
    @portfolios = ["All Portfolios"] + Group.all.collect { |group| group.name } + Portfolio.all.collect { |p| p.name }    
    @portfolio_name = params[:portfolio_name] ||= 'All Portfolios'
    @displays = [ 'All', 'Recent Dividends' ]
    @display = params[:display] ||= @displays.last

    @current_year_dates = Stock.current_year_dividend_dates
    stock_divs = Stock.calc_dividends(@portfolio_name, ['Stock','Fund']) 
    @stock_divs = stock_divs[0].sort_by { |y| -y[4] }  # [sym, divs, quantity, total_year, annual_yield]
    @current_divs = stock_divs[0].reject { |cd| cd[5].nil? }.sort_by { |y| -y[5].to_i }

    @annual_stock_divs_total = stock_divs[1]
    @monthly_stock_divs_total = stock_divs[2] # {:"01"=>0, :"02"=>0, :"03"=>182.1184, ...
    @value_stock_total = stock_divs[3] # {:"01"=>0, :"02"=>0, :"03"=>182.1184, ...
    @current_year = stock_divs[4]

    respond_to do |format|
        format.html
        format.js { render :layout => false, :template => "home/dividends" }  
    end           
  end
  
  def info
#    render :layout => false   
  end
    
  private

    def reload_update
      if ENV['RACK_ENV'] != 'development'      
        ironcache = IronCache::Client.new
        cache = ironcache.cache("my_cache")
        state = cache.get("poll_request").value
        if state == 'Complete'
          cache.put("poll_request", 'Waiting')
        elsif state == 'Idle'
          cache.put("poll_request", 'Waiting')
        end
      end  
    end
    
    def pad_with_zeros(value)
      value = value.split(/(?=(?:...)*$)/)
      padded = [value[0]]
      (value.count-1).times { |b| padded += ['000'] }
      padded = padded.join
      return padded
    end
  
    def sort_column
#      Stock.column_names.include?(params[:sort]) ? params[:sort] : "value"
      params[:sort] ||= 'change'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

  
end
