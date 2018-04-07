class History < ApplicationRecord
  
    def self.graph_data(portfolio_name, period)
      colors = [ 'Green', 'Yellow', 'Brown', 'Orange', 'Red', 'Pink', 'Purple', 'Maroon', 'Olive', 'Cyan', 'LightBlue', 'Magenta', 'Black','Blue','Gray'  ]

      years = [Date.today.year]
      months = (1..12)
      case period
      when 'From Start'
        years = (2013..(Date.today.year))
      when 'Year to Date'

      when 'Last Year'
        years = [Date.today.year-1]
      when 'Month to Date'
        months = [Date.today.month]
      end

      portfolio_id = portfolio_name == 'All Portfolios' ? 9999 : Portfolio.find_by_name(portfolio_name).id

       dates = [ ]
       values = [ ]
       time = '[ '
       years.each do |year|
         months.each do |month|
             results = month_totals(year,month,portfolio_id)
             values += results[0]
             time += results[1]
         end
       end
       time = time[0..-1] + ' ]'

      return [ values.to_s.gsub(" 0,"," ,").gsub("[0,","[ "), time ]

    end

    def self.month_totals(year, month, portfolio_id)

  #    dates = [ ]
  #    values = [ ]

  #    first_day = 1
  #    last_value = 0
  #    until last_value != 0 or first_day > 30
  #    record = History.where(:portfolio_id => portfolio_id).by_day( Time.local(year, month, first_day) )
  #        if record.empty?
  #          first_day += 1
  #        else
  #          previous_record = History.where(:portfolio_id => portfolio_id).where("id < ?", record.last.id).last
  #          puts record.last.id
  #          puts previous_record.id
  #          last_value = previous_record.total.to_f 
  #        end
  #    end

    time = ''
    values = [ ]
      last_value = 0
      (1..Time.days_in_month(month, year)).each do |day|
  #      date = Time.local(year, month, day)
  #      dates.push( date.strftime('%B') )
        time += " new Date(#{year}, #{month-1}, #{day}),"

  #      dates.push( date.strftime('%b %Y') )
  #      dates.push( date.strftime('%m/%d/%y') )
        new_value = History.where(:portfolio_id => portfolio_id, snapshot_date: Time.local(year, month, day))
       if new_value.last.nil? 
         new_value = 0
       else
         new_value = new_value.last.total.to_f 
       end
        values.push( new_value )
      end
      return values, time
    end
  
end
