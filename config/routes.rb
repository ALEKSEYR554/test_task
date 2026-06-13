Rails.application.routes.draw do
  # Swagger documentation
  mount Rswag::Ui::Engine => '/api-docs', as: :rswag_ui
  mount Rswag::Api::Engine => '/api-docs', as: :rswag_api

  # Authentication
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  # Admin namespace
  namespace :admin do
    resources :users
  end

  # Main resources
  resources :tasks
  resources :tags

  # Periodic occurrence actions
  post 'periodic_occurrence/cancel', to: 'periodic_occurrence#cancel'
  get 'periodic_occurrence/:task_id/edit/:date', to: 'periodic_occurrence#edit', as: :edit_periodic_occurrence
  patch 'periodic_occurrence/:task_id/:date', to: 'periodic_occurrence#update', as: :update_periodic_occurrence

  # Calendar
  get 'calendar', to: 'calendar#show'
  get 'calendar/day/:date', to: 'calendar#day', as: :calendar_day

  # API namespace
  namespace :api do
    namespace :v1 do
      resources :tasks, only: [:index, :show, :create, :update, :destroy]
      resources :tags, only: [:index, :show, :create, :update, :destroy]
      post 'auth/token', to: 'auth#token'
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root route
  root "calendar#show"
end