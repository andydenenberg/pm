
#       1. first run this on the old heroku data to collect the output locally
#       
#       heroku run bundle exec rails console | tee Total.data
#       
#       2. Then run this
#       
#       all = History.where(portfolio_id: 9999)
#       #p = Portfolio.find_by_name(name)
#       # all = p.histories.order(:snapshot_date)
#       #old_portfolio_id = p.id
#       #old_history_pid = p.histories.first.portfolio_id
#       
#       #puts "portfolio_name: #{name}"
#       #puts "old_portfolio_id: #{old_portfolio_id}"
#       #puts "old_history_id: #{old_history_pid}"
#       
#       all.each_with_index do |h,i|
#       puts "# #{i}"
#       puts "n = History.new"
#       puts "n.cash = #{h.cash}"
#       puts "n.stocks = #{h.stocks}"
#       puts "n.stocks_count = #{h.stocks_count}"
#       puts "n.options = #{h.options}"
#       puts "n.options_count = #{h.options_count}"
#       puts "n.total = #{h.total}"
#       puts "n.snapshot_date = '#{h.snapshot_date}'"
#       puts "n.portfolio_id = new_portfolio_id" #"#{h.portfolio_id}"
#       puts "n.daily_dividend = #{h.daily_dividend}"
#       puts "n.daily_dividend_date = '#{h.daily_dividend_date}'"
#       puts "n.save"
#       puts
#       end

