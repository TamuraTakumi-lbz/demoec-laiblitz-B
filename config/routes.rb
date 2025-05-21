Rails.application.routes.draw do
  devise_for :users,skip: [:registrations]
  # devise_for :users, only: [:sessions]

  devise_scope :user do
    get  "/users/sign_up", to: "devise/registrations#new",    as: :new_user_registration
    post "/users",         to: "devise/registrations#create", as: :user_registration
  end

  devise_scope :user do
    get  "/admin/sign_up", to: "admin_users#new",    as: :new_admin_registration
    post "/admin",        to: "admin_users#create", as: :admin_registration

    get "admin_users", to: "admin_users#index"
    delete "admin_users/:id", to: "admin_users#destroy", as: :admin_user_delete
    get "/items/dashboard", to: "items#dashboard"
  end
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "/items/dashboard", to: "items#dashboard"
  resources :items, only: [:destroy]

  resources :items, only: [:show, :new, :create ,:create, :edit, :update] do
    member do
      get 'order',to: 'orders#new',as: 'order'
      post 'order',to: 'orders#create'
    end
  end

  resources :notifications, only: [:index, :new, :create, :edit, :update]
  
  # Defines the root path route ("/")
  # root "posts#index"
  root "items#index"
  resources :items

end
