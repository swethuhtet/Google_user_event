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
end
