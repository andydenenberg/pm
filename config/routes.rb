Rails.application.routes.draw do
  resources :stocks
  root 'home#index'

  get 'home', to: 'home#index'  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
