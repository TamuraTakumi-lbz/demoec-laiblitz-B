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
  end
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "/items/dashboard", to: "items#dashboard"
  resources :items, only: [:destroy]
  # Defines the root path route ("/")
  # root "posts#index"
  root "items#index"
  resources :items, only: [:show, :new, :create, :edit, :update]
end
