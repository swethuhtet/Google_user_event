Rails.application.routes.draw do
  get 'guests/index'
  
  namespace :api do
    resources :users
  end

  resources :users do
    collection do
      get :new_import, to: 'users#new_import' 
      post :import, to: 'users#import'
    end
  end
  resources :events do
    resources :event_details, only: [:index, :show, :create, :new]
  end

  resources :guests do
    collection do
      get :new_import, to: 'guests#new_import' 
      post :import, to: 'guests#import'
    end
  end
  
  root 'users#index'
  get "up" => "rails/health#show", as: :rails_health_check

  #google auth routes
  get 'auth/:provider/callback', to: 'sessions#googleAuth'
  get 'auth/failure', to: redirect('/')  
  delete '/auth/google_oauth2/cancel/:id', to: 'sessions#cancel_google_oauth2', as: 'cancel_google_oauth2'
end
