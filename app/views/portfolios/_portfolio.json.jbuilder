json.extract! portfolio, :id, :user_id, :name, :cash, :created_at, :updated_at
json.url portfolio_url(portfolio, format: :json)
