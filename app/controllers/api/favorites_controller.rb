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

  def index
    favorites = @current_user.favorites.includes(restaurant: :photos)

    render json: favorites.map { |favorite|
      next unless favorite.restaurant

      photos = favorite.restaurant.photos.order(:position).map(&:url)
      {
        id: favorite.id,
        place_id: favorite.restaurant.place_id,
        name: favorite.restaurant.name,
        vicinity: favorite.restaurant.vicinity,
        rating: favorite.restaurant.rating,
        price_level: favorite.restaurant.price_level,
        website: favorite.restaurant.website,
        url: favorite.restaurant.url,
        postal_code: favorite.restaurant.postal_code,
        user_ratings_total: favorite.restaurant.user_ratings_total,
        formatted_phone_number: favorite.restaurant.formatted_phone_number,
        photos: photos
      }
    }.compact
  end
end
