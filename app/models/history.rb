class History < ApplicationRecord
  
    def self.graph_data(portfolio_name, period)
      colors = [ 'Green', 'Yellow', 'Brown', 'Orange', 'Red', 'Pink', 'Purple', 'Maroon', 'Olive', 'Cyan', 'LightBlue', 'Magenta', 'Black','Blue','Gray'  ]

      year = Date.current.year
      years = [year]
      months = (1..12)
      case period
      when 'from Start'
        year = "2013-#{year}"
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
      
       p_ids_group = Lib.translate_groupids(portfolio_name)
       
       if !p_ids_group[1] and p_ids_group[0].is_a?(Array) # All Portfolios not a group, but multiples
         p_ids_group[0] = 9999
       end

        
       dates = [ ]
       values = [ ]
       time = '[ '
       years.each do |year|
         months.each do |month|
#             results = group_id ? month_totals_group(year, month, group_id) : month_totals(year,month,portfolio_id) 
             results = month_totals(year,month,p_ids_group ) 
             values += results[0]
             time += results[1]
         end
       end
       time = time[0..-2] + ' ]'
      return [ values, time, year ]

    end

    def self.month_totals(year, month, p_ids)
    time = ''
    values = [ ]
      last_value = 0
      (1..Time.days_in_month(month, year)).each do |day|
        time += " new Date(#{year}, #{month-1}, #{day}),"
        selected_date = Time.local(year, month, day)
        new_value = History.where(:portfolio_id => p_ids[0]).where(:snapshot_date => selected_date.beginning_of_day..selected_date.end_of_day)
        if p_ids[1] # group is true
          new_value = new_value.sum(0) { |v| v.total.to_f.round(0) }
        else                 
           if new_value.last.nil? 
             new_value = 0
           else
             new_value = new_value.last.total.to_f.round(0) 
           end
        end
        values.push( new_value )
      end
      return values, time
    end
  


        def self.graph_data_comparison(group_name, period)

          year = Date.current.year
          years = [year]
          months = (1..12)
          case period
          when 'from Start'
            year = "2013-#{year}"
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

          p_ids = Group.find_by_name(group_name).portfolios.collect { |p| p.id }
          reference_level = 0
          p_ids.each do |p|
            r = History.where(portfolio_id: p, snapshot_date: Date.today.beginning_of_year..Date.today).order('snapshot_date').first
#            puts "#{r.snapshot_date} - #{r.portfolio_id} - #{r.total} "
            reference_level += r.total
          end
          
          
           absolute = [ ]
           relative = [ ]
           time = '[ '
           years.each do |year|
             months.each do |month|
                 results = month_totals_comparison(year, month, p_ids, reference_level)
                 absolute += results[0]
                 relative += results[1]
             end
           end
          return [ relative, absolute ]

        end


    def self.month_totals_comparison(year, month, p_ids, reference_level)
    values = [ ]
    relative = [ ]
      (1..Time.days_in_month(month, year)).each do |day|
        selected_date = Time.local(year, month, day)
        value = History.where(:portfolio_id => p_ids).where(:snapshot_date => selected_date.beginning_of_day..selected_date.end_of_day)
        if value.count == p_ids.count 
          value = value.sum(0) { |v| v.total }.to_f
          rel = ((value / reference_level) - 1).to_f 
          
          
          puts "#{month}/#{day}/#{year} - #{reference_level} - #{value} - #{rel}"
          
          
          values.push( ["#{month}/#{day}/#{year}", value ] )
          relative.push( ["#{month}/#{day}/#{year}", rel ] )
        end
      end
      return values, relative
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
#    Stock.refresh_all_dividends
    Stock.refresh_dividends

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
