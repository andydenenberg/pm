json.extract! stock, :id, :portfolio_id, :title, :body, :purchase_price, :quantity, :symbol, :name, :portfolio_id, :purchase_date, :strike, :expiration_date, :stock_option, :created_at, :updated_at
json.url stock_url(stock, format: :json)
