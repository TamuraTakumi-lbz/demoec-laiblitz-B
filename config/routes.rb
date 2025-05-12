Rails.application.routes.draw do
  resources :items
  root "items#index"
  get "dashboard", to: "items#index"
end
