Rails.application.routes.draw do
  resources :histories
  resources :portfolios
  resources :stocks
  root 'portfolios#index'
  get 'home', to: 'home#index'  
  
#  get "/update_prices" => 'portfolios#update_prices', as: 'update_prices'
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
