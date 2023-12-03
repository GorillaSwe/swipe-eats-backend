Rails.application.routes.draw do
  namespace :api do
    resources :restaurants, only: [:index] do
      collection do
        get :search
      end
    end

    resources :users, only: [:create] do
      collection do
        get :search
      end
    end
    
    resources :favorites, only: [:create, :index] do
      collection do
        get :other_index,:latest,:followed
      end
    end
    delete 'favorites/destroy_by_place_id/:place_id', to: 'favorites#destroy_by_place_id'

    resources :follow_relationships, only: [:create, :index] do
      collection do
        get :counts
      end
    end
    delete 'follow_relationships/destroy_by_user_sub/:user_sub', to: 'follow_relationships#destroy_by_user_sub'
  end
end