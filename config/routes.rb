Rails.application.routes.draw do
  namespace :api do
    resources :restaurants, only: [:index] do
      collection do
        get :search
      end
    end
    resources :users, only: [:create]
    resources :favorites, only: [:create, :index] 
    delete 'favorites/destroy_by_place_id/:place_id', to: 'favorites#destroy_by_place_id'
  end
end