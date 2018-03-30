class AddDailydividendToHistory < ActiveRecord::Migration[5.1]
  def change
    add_column :histories, :daily_dividend, :decimal, :precision => 10, :scale => 2
    add_column :histories, :daily_dividend_date, :datetime
  end
end
