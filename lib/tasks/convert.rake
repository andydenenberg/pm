namespace :convert do

  desc 'Create some Stocks'
  quants = [ 80431, 31000, 18133, 20000, 28778 ]
  symbols = ['csco','crm','msft','intc','amat']
  costs = [ 2104879.27, 2168140.00, 796038.70, 554400.00, 458721.32]
    task :stocks => :environment do
      symbols.each_with_index do |stock, i|
        s = Stock.create!( :symbol => stock,
                           #:name => s[1][0..15],
                           :quantity => quants[i],
                           :purchase_price => costs[i],
                           #:portfolio_id => portfolio.id,
                           #:stock_option => stock_option,
                           #:strike => strike,
                           #:expiration_date => expiration_date,
                           #:purchase_date => '12/31/2012' 
                        )
      end
      
    end

end