Rails.application.routes.draw do
  get 'sessions/new'

  resources :users
#  resources :histories
#  resources :portfolios
#  resources :stocks
  
  resources :sessions
  get 'signup', to: 'users#new', as: 'signup'
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  
  
  root 'home#consolidated'
  get 'highlights_modal', to: 'home#highlights_modal'
  get 'consolidated', to: 'home#consolidated'
  get 'positions', to: 'home#positions'
  get 'graphs', to: 'home#graphs'
  get 'chart_comparison', to: 'home#chart_comparison'
  get 'highlights', to: 'home#highlights'
  get 'dividends_new', to: 'home#dividends'
  get 'poll_check', to: 'home#poll_check' 
  get 'poll_set', to: 'home#poll_set'
  get 'system', to: 'home#system_config' 
  post 'system', to: 'home#system_config_save' 
  
#  get 'demo', to: 'home#demo'
#  get 'home', to: 'home#index'
  get 'info', to: 'home#info' 
#  get 'poll_check', to: 'portfolios#poll_check' 
#  get 'dividends', to: 'stocks#dividends'

  
#  get "/update_prices" => 'portfolios#update_prices', as: 'update_prices'
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
