Rails.application.routes.draw do
  namespace :api do
    resources :restaurants, only: [:index, :show]
    resources :users, only: [:create]
  end
end
