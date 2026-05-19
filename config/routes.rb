Rails.application.routes.draw do
  root "dashboards#show"

  # Auth
  get    "login",  to: "sessions#new"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # Signup
  get  "signup", to: "registrations#new",    as: :signup
  post "signup", to: "registrations#create"

  # Authenticated influencer area
  resource  :dashboard,       only: [ :show ]
  resources :flash_campaigns, only: [ :index, :new, :create, :show ]

  # Public fan landing — short path so it fits in IG stories
  resources :campaign_sales, path: "c", only: [ :show ] do
    resources :flash_orders, only: [ :create ]
  end

  # Rails health probe
  get "up" => "rails/health#show", as: :rails_health_check
end
