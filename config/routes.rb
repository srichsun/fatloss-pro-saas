Rails.application.routes.draw do
  # Authentication Routes
  get  "login",  to: "sessions#new"
  post "login",  to: "sessions#create"
  delete '/logout', to: 'sessions#destroy'

  # Registration Routes (Coach Sign up)
  get  "signup", to: "registrations#new"
  post "signup", to: "registrations#create"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Root page to list all coaches (Landing Page)
  root "tenants#index"

  # Individual coach room (SaaS Tenant Space)
  resources :tenants, only: [:show]

  # Define a dynamic parameter named :subdomain
  # 'as: :coach_room' generates the 'coach_room_path' helper method
  get "/:subdomain", to: "tenants#show", as: :coach_room
end


