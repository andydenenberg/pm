class AddDividenddateToPrice < ActiveRecord::Migration[5.1]
  def change
    add_column :prices, :daily_dividend_date, :datetime
  end
end
