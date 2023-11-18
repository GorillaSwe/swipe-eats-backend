Rails.application.routes.draw do
  namespace :api do
    resources :restaurants, only: [:index, :show]
    resources :users, only: [:create]
    resources :favorites, only: [:create, :index]
  end
end
