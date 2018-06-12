json.extract! history, :id, :cash, :stocks, :stocks_count, :options, :options_count, :total, :snapshot_date, :portfolio_id, :daily_dividend, :daily_dividend_date, :created_at, :updated_at
json.url history_url(history, format: :json)
