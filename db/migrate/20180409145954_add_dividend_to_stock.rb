class AddDividendToStock < ActiveRecord::Migration[5.1]
  def change
    add_column :stocks, :daily_dividend, :decimal
    add_column :stocks, :daily_dividend_date, :datetime
  end
end
