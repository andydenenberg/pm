require 'test_helper'

class StockTest < ActiveSupport::TestCase

#   test "the truth" do
#     portfolio = Portfolio.first
#     puts portfolio.name
#     stock = Stock.table_data(portfolio.name, 'change', 'asc')
#     puts stock.first.count
#     assert stock
#   end

   test "distinct symbols" do
     symbols = Stock.all.distinct.pluck(:symbol)
     assert symbols
   end
   
   test "get total values" do
     symbols = Stock.all.distinct.pluck(:symbol)
     stocks_funds = Stock.where(stock_option: 'Stock').or(Stock.where(stock_option: 'Fund'))
     values = symbols.collect { |sym| [ sym, stocks_funds.where(symbol: sym).sum(0) { |data| (data.quantity * (data.price ||= 0) ).to_f }] }
     change = symbols.collect { |sym| [ sym, stocks_funds.where(symbol: sym).sum(0) { |data| (data.quantity * (data.change ||= 0) ).to_f }] }
   end

   test "get portfolio values" do
     start = Time.now
     data = Portfolio.table_data(nil, 1)
     finish = Time.now
     diff = finish - start
     puts "\nPortfolio.table_data: #{diff}"
     
   end
      
   test "get total & change values" do
     start = Time.now
     data = Stock.table_data('All Portfolios', 'value', 'asc')
     finish = Time.now
     diff = finish - start
     puts "\nStock.table_data: #{diff}"
     
   end
   
end
