Rails.application.routes.draw do
  resources :histories
  resources :portfolios
  resources :stocks
  root 'home#consolidated'
  get 'consolidated', to: 'home#consolidated'
  get 'positions', to: 'home#positions'
  get 'graphs', to: 'home#graphs'
  get 'highlights', to: 'home#highlights'
  get 'dividends_new', to: 'home#dividends'
  get 'poll_check_new', to: 'home#poll_check' 
  get 'poll_set', to: 'home#poll_set' 
  
#  get 'demo', to: 'home#demo'
  get 'home', to: 'home#index'
  get 'info', to: 'home#info' 
  get 'poll_check', to: 'portfolios#poll_check' 
  get 'dividends', to: 'stocks#dividends'

  
#  get "/update_prices" => 'portfolios#update_prices', as: 'update_prices'
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
