class History < ApplicationRecord
  
    def self.graph_data(portfolio_name, period)
      colors = [ 'Green', 'Yellow', 'Brown', 'Orange', 'Red', 'Pink', 'Purple', 'Maroon', 'Olive', 'Cyan', 'LightBlue', 'Magenta', 'Black','Blue','Gray'  ]

      year = Date.current.year
      years = [year]
      months = (1..12)
      case period
      when 'from Start'
        years = (2013..(Date.today.year))
      when 'Last 3 Years'
        year = "#{year-2}-#{year}"
        years = [Date.today.year-2, Date.today.year-1, Date.today.year]
      when 'Last 2 Years'
        year = "#{year-1}-#{year}"
        years = [Date.today.year-1, Date.today.year]
      when 'Year to Date'
        months = (1..12) # Date.today.month+1)
      when 'Month to Date'
        months = [Date.today.month]
      end
      
      group_id = nil
      case portfolio_name
        when 'All Portfolios' 
          portfolio_id = 9999
        when 'Personel Portfolios'
          portfolio_id = 0
          group_id = 1
        when 'All SLATs'
          portfolio_id = 0
          group_id = 2
        when 'Retirement Portfolios'
          portfolio_id = 0
          group_id = 3
        else
          portfolio_id = Portfolio.find_by_name(portfolio_name).id
        end
       dates = [ ]
       values = [ ]
       time = '[ '
       years.each do |year|
         months.each do |month|
             results = group_id ? month_totals_group(year, month, group_id) : month_totals(year,month,portfolio_id) 
             values += results[0]
             time += results[1]
         end
       end
       time = time[0..-2] + ' ]'
       
       puts values.inspect
       
      return [ values, time, year ]

    end

    def self.month_totals_group(year, month, group_id)
    time = ''
    values = [ ]
      (1..Time.days_in_month(month, year)).each do |day|
        time += " new Date(#{year}, #{month-1}, #{day}),"
        selected_date = Time.local(year, month, day)
        group = Portfolio.where(group_id: group_id).collect { |p| p.id }
        new_value = History.where(portfolio_id: group).where(:snapshot_date => selected_date.beginning_of_day..selected_date.end_of_day).sum(0) { |v| v.total.to_f.round(0) }        
        values.push( new_value )
      end
      return values, time
    end


    def self.month_totals(year, month, portfolio_id)
    time = ''
    values = [ ]
      last_value = 0
      (1..Time.days_in_month(month, year)).each do |day|
        time += " new Date(#{year}, #{month-1}, #{day}),"
        selected_date = Time.local(year, month, day)
        new_value = History.where(:portfolio_id => portfolio_id).where(:snapshot_date => selected_date.beginning_of_day..selected_date.end_of_day)        
       if new_value.last.nil? 
         new_value = 0
       else
         new_value = new_value.last.total.to_f.round(0) 
       end
        values.push( new_value )
      end
      return values, time
    end
  
  
  def daily_snapshot_total
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
  end
  
  def self.daily_snapshot # store in History record in DB

    Stock.refresh_all('Stock')
    Stock.refresh_all('Option')
    Stock.refresh_all('Fund')
    Stock.refresh_all_dividends

    date = Time.now.beginning_of_day()
    
    total_cash = 0
    total_stocks = 0
    total_stocks_change = 0
    total_stocks_count = 0
    total_options = 0
    total_options_count = 0
    total_daily_dividend = 0
    total_all = 0
    
    Portfolio.all.each do |portfolio|
      all_secs = portfolio.stocks
      hist = History.new ( { portfolio_id: portfolio.id } )
      hist.snapshot_date = date
      hist.cash = portfolio.cash
        total_cash += portfolio.cash 

      stocks = all_secs.where(:stock_option => 'Stock').or(all_secs.where(:stock_option => 'Fund'))
        hist.stocks_count = stocks.count
          total_stocks_count += stocks.count
        hist.stocks = stocks.reduce(0) { |sum, stock| sum + ( stock.quantity * stock.price ) }
          total_stocks += hist.stocks

        stocks_change = stocks.reduce(0) { |sum, stock| sum + ( stock.quantity * stock.change ) }
          total_stocks_change += stocks_change

        hist.daily_dividend = stocks.reduce(0) { |sum, stock| sum + ( stock.daily_dividend * stock.quantity ) }
          total_daily_dividend += hist.daily_dividend
        hist.daily_dividend_date = Time.now.beginning_of_day()
          
      options = all_secs.where('stock_option LIKE ?', '%' + 'Option' + '%')
        hist.options_count = options.count
          total_options_count += options.count
        hist.options = options.reduce(0) { |sum, option| sum + option.quantity * option.price * 100 }
          total_options = hist.options
      hist.total = hist.options + hist.stocks + hist.cash
          total_all += hist.total
      hist.save          
    end
      h = History.create ( { portfolio_id: 9999, cash: total_cash, snapshot_date: date,
                           stocks: total_stocks, stocks_count: total_stocks_count, 
                           options: total_options, options_count: total_options_count,
                           daily_dividend: total_daily_dividend, daily_dividend_date: date,
                           total: total_all } )

    return total_all, total_stocks_change

  end
  
end
