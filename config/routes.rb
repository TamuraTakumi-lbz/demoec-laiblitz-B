Rails.application.routes.draw do
  resources :items, only: [:show]
end
