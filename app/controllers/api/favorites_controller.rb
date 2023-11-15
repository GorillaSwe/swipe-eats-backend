class Api::FavoritesController < SecuredController
  def create
    restaurant = Restaurant.find_by(place_id: params[:place_id])

    unless restaurant
      render json: { error: 'Restaurant not found' }, status: :not_found
      return
    end
    existing_favorite = @current_user.favorites.find_by(restaurant_id: restaurant.id)

    if existing_favorite.nil?
      favorite = @current_user.favorites.build(restaurant_id: restaurant.id)

      if favorite.save
        render json: favorite, status: :created
      else
        render json: favorite.errors, status: :unprocessable_entity
      end
    else
      render json: { message: 'Already favorited' }, status: :ok
    end
  end
end
