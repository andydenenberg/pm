class CreateHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :histories do |t|
      t.decimal :cash
      t.decimal :stocks
      t.integer :stocks_count
      t.decimal :options
      t.decimal :options_count
      t.decimal :total
      t.datetime :snapshot_date
      t.integer :portfolio_id
      t.decimal :daily_dividend
      t.datetime :daily_dividend_date

      t.timestamps
    end
  end
end
