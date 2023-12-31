Rails.application.routes.draw do
  namespace :api do
    resources :restaurants, only: [:index] do
      get :search, on: :collection
    end

    resources :users, only: [:create] do
      collection do
        get :search
        get :get_user_profile
      end
    end
    
    resources :favorites, only: [:create, :index] do
      collection do
        get :other_index
        get :latest
        get :followed
        get :counts
      end
    end
    delete 'favorites/destroy_by_place_id/:place_id', to: 'favorites#destroy_by_place_id'

    resources :follow_relationships, only: [:create, :index] do
      collection do
        get :counts
        get :following
        get :followers
      end
    end
    delete 'follow_relationships/destroy_by_user_sub/:user_sub', to: 'follow_relationships#destroy_by_user_sub'

    resource :locations do
      get :search, on: :collection
    end
  end
end