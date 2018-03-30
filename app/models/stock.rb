class Stock < ApplicationRecord
  belongs_to :portfolio
end

#   rails g scaffold Stock portfolio:references title:string body:text purchase_price:decimal quantity:decimal symbol:string name:string portfolio_id:integer purchase_date:string strike:decimal expiration_date:string stock_option:string
