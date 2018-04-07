Rails.application.routes.draw do
  resources :histories
  resources :portfolios
  resources :stocks
  root 'home#index'

  get 'home', to: 'home#index'  
  
  get "/refresh" => 'home#refresh', as: 'refresh'
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
