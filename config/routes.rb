Rails.application.routes.draw do
  
  namespace :api do
    resources :users
  end

  resources :users
  resources :events do
    resources :event_details, only: [:index, :show, :create, :new]
  end
  
  root 'users#index'
  get "up" => "rails/health#show", as: :rails_health_check

  #google auth routes
  get 'auth/:provider/callback', to: 'sessions#googleAuth'
  get 'auth/failure', to: redirect('/')  
  delete '/auth/google_oauth2/cancel/:id', to: 'sessions#cancel_google_oauth2', as: 'cancel_google_oauth2'
end
