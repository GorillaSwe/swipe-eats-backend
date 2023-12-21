class Api::FavoritesController < SecuredController
  skip_before_action :authorize_request, only: [:other_index, :latest, :counts]

  def create
    restaurant = Restaurant.find_by(place_id: params[:place_id])
    return render json: { error: 'Restaurant not found' }, status: :not_found unless restaurant
  
    favorite = @current_user.favorites.find_or_initialize_by(restaurant_id: restaurant.id)
    favorite.rating = params[:user_rating] if params[:user_rating].present?
    favorite.comment = params[:user_comment] if params[:user_comment].present?
  
    if favorite.save
      render json: favorite_to_json(favorite), status: favorite.new_record? ? :created : :ok
    else
      render json: favorite.errors, status: :unprocessable_entity
    end
  end

  def index
    render_favorites_json(@current_user.favorites, 9)
  end

  def destroy_by_place_id
    restaurant = Restaurant.find_by(place_id: params[:place_id])
    return render json: { error: 'Restaurant not found' }, status: :not_found unless restaurant

    favorite = @current_user.favorites.find_by(restaurant: restaurant)
    return render json: { error: 'Favorite not found' }, status: :not_found unless favorite

    favorite.destroy
    render json: { message: 'Favorite deleted successfully' }, status: :ok
  end

  def other_index
    user_sub = URI.decode_www_form_component(params[:user_sub])
    user = User.find_by(sub: user_sub)
    return render json: { error: 'User not found' }, status: :not_found unless user

    render_favorites_json(user.favorites, 9)
  end

  def latest
    render_favorites_json(Favorite.latest.includes(:user, restaurant: :photos), 5)
  end

  def followed
    followed_users = @current_user.following
    render_favorites_json(Favorite.latest.includes(:user, restaurant: :photos).where(user: followed_users), 5)
  end

  def counts
    user_sub = URI.decode_www_form_component(params[:user_sub])
    user = User.find_by(sub: user_sub)
    return render json: { error: 'User not found' }, status: :not_found unless user

    favorites_count = user.favorites.count
    render json: { favoritesCount: favorites_count }, status: :ok
  end

  private

  def render_favorites_json(favorites_scope, default_per_page)
    page = params.fetch(:page, 1)
    per_page = params.fetch(:per_page, default_per_page)

    favorites = favorites_scope.includes(restaurant: :photos).page(page).per(per_page)

    favorites_json = favorites.map do |favorite|
      next unless favorite.restaurant
      favorite_to_json(favorite)
    end.compact

    render json: { favorites: favorites_json, meta: pagination_meta(favorites) }
  end

  def favorite_to_json(favorite)
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
      created_at: favorite.created_at,
      is_favorite: true,
      user_rating: favorite.rating,
      user_comment: favorite.comment
    }
  end

  def pagination_meta(favorites)
    {
      total_pages: favorites.total_pages,
      current_page: favorites.current_page,
      next_page: favorites.next_page
    }
  end
end
