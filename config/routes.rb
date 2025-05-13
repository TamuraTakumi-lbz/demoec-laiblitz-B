Rails.application.routes.draw do
  devise_for :users

  resources :users
  root "items#index"
  resources :items, only: [:show]
end
