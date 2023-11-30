class Api::FavoritesController < SecuredController
  skip_before_action :authorize_request, only: [:latest]

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

  def destroy_by_place_id
    restaurant = Restaurant.find_by(place_id: params[:place_id])

    unless restaurant
      render json: { error: 'Restaurant not found' }, status: :not_found
      return
    end

    favorite = @current_user.favorites.find_by(restaurant_id: restaurant.id)

    if favorite
      favorite.destroy
      render json: { message: 'Favorite deleted successfully' }, status: :ok
    else
      render json: { error: 'Favorite not found' }, status: :not_found
    end
  end

  def latest
    page = params[:page] || 1
    per_page = 5

    latest_favorites = Favorite.latest.includes(:user, restaurant: :photos).page(page).per(per_page)


    favorites_json = latest_favorites.map do |favorite|
      next unless favorite.restaurant

      photos = favorite.restaurant.photos.order(:position).map(&:url)
      {
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
        photos: photos,
        user_name: favorite.user.name,
        user_picture: favorite.user.picture,
        created_at: favorite.created_at
      }
    end.compact

    render json: {
      favorites: favorites_json,
      meta: {
        total_pages: latest_favorites.total_pages,
        current_page: latest_favorites.current_page,
        next_page: latest_favorites.next_page
      }
    }
  end
end
