class Api::FavoritesController < SecuredController
  skip_before_action :authorize_request, only: [:other_index, :latest, :counts]

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
    page = params[:page] || 1
    per_page = 9

    favorites = @current_user.favorites.includes(restaurant: :photos).page(page).per(per_page)

    favorites_json = favorites.map do |favorite|
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
    end.compact

    render json: {
      favorites: favorites_json,
      meta: {
        total_pages: favorites.total_pages,
        current_page: favorites.current_page,
        next_page: favorites.next_page
      }
    }
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

  def other_index
    page = params[:page] || 1
    per_page = 9
    
    user_sub = URI.decode_www_form_component(params[:user_sub])
    user = User.find_by(sub: user_sub)
    return render json: { error: 'User not found' }, status: :not_found unless user

    favorites = user.favorites.includes(restaurant: :photos).page(page).per(per_page) 
    
    favorites_json =  favorites.map do |favorite|
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
        user_sub: favorite.user.sub,
        user_name: favorite.user.name,
        user_picture: favorite.user.picture,
        created_at: favorite.created_at
      }
    end.compact

    render json: {
      favorites: favorites_json,
      meta: {
        total_pages: favorites.total_pages,
        current_page: favorites.current_page,
        next_page: favorites.next_page
      }
    }
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
        user_sub: favorite.user.sub,
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

  def followed
    page = params[:page] || 1
    per_page = 5

    followed_users = @current_user.following
    favorites = Favorite.latest.includes(:user, restaurant: :photos).where(user: followed_users).page(page).per(per_page)

    favorites_json = favorites.map do |favorite|
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
        user_sub: favorite.user.sub,
        user_name: favorite.user.name,
        user_picture: favorite.user.picture,
        created_at: favorite.created_at
      }
    end.compact

    render json: {
      favorites: favorites_json,
      meta: {
        total_pages: favorites.total_pages,
        current_page: favorites.current_page,
        next_page: favorites.next_page
      }
    }
  end

  def counts
    user_sub = URI.decode_www_form_component(params[:user_sub])
    user = User.find_by(sub: user_sub)

    if user
      favorites_count = user.favorites.count

      render json: {
        favoritesCount: favorites_count
      }, status: :ok
    else
      render json: { error: 'Favorites not found' }, status: :not_found
    end
  end
end
