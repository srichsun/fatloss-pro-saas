Rails.application.routes.draw do
  root "dashboards#show" # Redirect to login if not authenticated
  
  # Single entry point for dashboard
  resource :dashboard, only: [:show]

  get "dashboards/show"
  # Authentication Routes
  get  "login",  to: "sessions#new"
  post "login",  to: "sessions#create"
  delete '/logout', to: 'sessions#destroy'

  # Registration Routes (Coach Sign up)
  get  "signup", to: "registrations#new", as: :signup
  post "signup", to: "registrations#create"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # 1. Influencer/Coach Dashboard (Management)
  resources :flash_campaigns, only: [:index, :new, :create, :show]

  # 2. Fan/Public Landing Page (Publicly accessible)
  # We use a custom path 'c/:id' to make the URL short for IG stories
  resources :campaign_sales, path: 'c', oncology: [:show] do
    resources :flash_orders, only: [:create]
  end

  # Individual coach room (SaaS Tenant Space)
  resources :tenants, only: [:show]
  resources :orders

  # Define a dynamic parameter named :subdomain
  # 'as: :coach_room' generates the 'coach_room_path' helper method
  get "/:subdomain", to: "tenants#show", as: :coach_room
end


