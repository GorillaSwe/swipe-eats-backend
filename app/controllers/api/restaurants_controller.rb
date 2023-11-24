class Api::RestaurantsController < ApplicationController
  before_action :set_google_places_client, only: [:index, :restaurant_details, :search]
  before_action :optional_authorize_request, only: [:search]

  ERROR_PHOTO = "https://developers.google.com/static/maps/documentation/maps-static/images/quota.png?hl=ja"

  def index
    return render_error(:bad_request, '位置情報が提供されていません') if params[:latitude].blank? || params[:longitude].blank?

    begin
      restaurants = fetch_restaurants_from_google
    rescue => e
      return render_error(:bad_request, e.message)
    end

    if params[:price].present?
      selected_levels = params[:price].map(&:to_i)
      restaurants = restaurants.select { |restaurant| selected_levels.include?(restaurant.price_level.to_i) }
      return render_error(:bad_request, 'レストランが見つかりません。検索条件を変更して再度お試しください。') if restaurants.blank?
    end

    restaurants = restaurants.select do |restaurant|
      distance_in_meters(restaurant.lat, restaurant.lng, params[:latitude].to_f, params[:longitude].to_f) <= params[:radius].to_i
    end
    return render_error(:bad_request, 'レストランが見つかりません。検索条件を変更して再度お試しください。') if restaurants.blank?

    processed_restaurants = sort_restaurants(process_restaurant_data(restaurants)).reverse

    render json: { status: 200, message: processed_restaurants }
  end

  def search
    return render_error(:bad_request, '値が提供されていません') if params[:query].blank?

    handle_google_places_error do
      restaurants = @client.spots_by_query(
        params[:query],
        types: 'restaurant',
        language: 'ja'
      )

      raise "レストランが見つかりません。検索条件を変更して再度お試しください。" if restaurants.blank?
  
      processed_restaurants = process_restaurant_data(restaurants)

      processed_restaurants = add_favorites_to_restaurants(processed_restaurants) if @current_user

      render json: { status: 200, message: processed_restaurants }
    end
  end
  
  private

  def set_google_places_client
    @client = GooglePlaces::Client.new(
      ENV['GOOGLE_API_KEY'])
  end

  def handle_google_places_error
    yield
  rescue GooglePlaces::OverQueryLimitError
    render_error(:too_many_requests, "クエリ上限に達しました。")
  rescue GooglePlaces::RequestDeniedError
    render_error(:forbidden, "リクエストが拒否されました。")
  rescue GooglePlaces::InvalidRequestError
    render_error(:bad_request, "無効なリクエストです。")
  rescue GooglePlaces::NotFoundError
    render_error(:not_found, "該当する結果が見つかりません。")
  rescue GooglePlaces::UnknownError
    render_error(:internal_server_error, "未知のエラーが発生しました。")
  rescue => e
    render_error(:internal_server_error, "予期しないエラーが発生しました：#{e.message}")
  end

  def fetch_restaurants_from_google
    handle_google_places_error do
      restaurants = @client.spots(
        params[:latitude], params[:longitude],
        name: params[:category],
        radius: params[:radius],
        types: 'restaurant',
        language: 'ja'
      )
  
      raise "レストランが見つかりません。検索条件を変更して再度お試しください。" if restaurants.blank?
  
      restaurants
    end
  end

  def distance_in_meters(lat1, lng1, lat2, lng2)
    rad_per_deg = Math::PI / 180
    r = 6371 * 1000 # Earth radius in meters
    dlat_rad = (lat2 - lat1) * rad_per_deg
    dlng_rad = (lng2 - lng1) * rad_per_deg
  
    a = Math.sin(dlat_rad / 2)**2 + Math.cos(lat1 * rad_per_deg) * Math.cos(lat2 * rad_per_deg) * Math.sin(dlng_rad / 2)**2
    (2 * r * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))).to_i
  end

  def process_restaurant_data(restaurants)
    restaurants.map do |restaurant|
      details = get_restaurant_details(restaurant)
      {
        place_id:    restaurant.place_id,
        name:        restaurant.name,
        lat:         restaurant.lat,
        lng:         restaurant.lng,
        rating:      restaurant.rating,
        price_level: restaurant.price_level,
        photos:      details[:photos],
        vicinity:    details[:vicinity],
        website:     details[:website],
        url:         details[:url],
        postal_code: details[:postal_code],
        user_ratings_total: details[:user_ratings_total],
        formatted_phone_number: details[:formatted_phone_number]
      }
    end
  end

  def get_restaurant_details(restaurant)
    existing_details = Restaurant.find_by(place_id: restaurant.place_id)
  
    return format_existing_details(existing_details) if existing_details

    new_details = @client.spot(restaurant.place_id, language: 'ja')

    if new_details.present?
      details = format_new_details(new_details)
      SaveRestaurantJob.perform_later(details)
      details[:photos] = if new_details.photos.present?
        new_details.photos.map { |photo| "https://maps.googleapis.com/maps/api/place/photo?maxwidth=580&photoreference=#{photo.photo_reference}&key=#{ENV['GOOGLE_API_KEY']}" }
      else
        [ERROR_PHOTO]
      end
      details
    end
  end

  def format_existing_details(details)
    photos = details.photos.order(:position).pluck(:url)
    photos = [ERROR_PHOTO] if photos.blank?
    {
      photos: photos,
      vicinity: details.vicinity,
      website: details.website,
      url: details.url,
      postal_code: details.postal_code,
      user_ratings_total: details.user_ratings_total,
      formatted_phone_number: details.formatted_phone_number
    }
  end

  def format_new_details(details)
    {
      place_id: details.place_id,
      name: details.name,
      lat: details.lat,
      lng: details.lng,
      vicinity: details.vicinity,
      rating: details.rating,
      price_level: details.price_level,
      photos: details.photos.map(&:photo_reference),
      website: details.website,
      url: details.url,
      postal_code: details.postal_code,
      user_ratings_total: details.json_result_object["user_ratings_total"],
      formatted_phone_number: details.formatted_phone_number
    }
  end

  def sort_restaurants(restaurants)
    case params[:sort]
    when 'prominence'
      restaurants
    when 'distance'
      restaurants.sort_by { |restaurant| Math.sqrt((restaurant[:lat] - params[:latitude].to_f)**2 + (restaurant[:lng] - params[:longitude].to_f)**2) }
    when 'highPrice'
      restaurants.sort_by { |restaurant| -restaurant[:price_level].to_i }
    when 'lowPrice'
      restaurants.sort_by { |restaurant| restaurant[:price_level].to_i }
    when 'highRating'
      restaurants.sort_by { |restaurant| -restaurant[:rating].to_f }
    else
      restaurants
    end
  end

  def render_error(status, message)
    status_mapping = {
      too_many_requests: 429,
      forbidden: 403,
      bad_request: 400,
      not_found: 404,
      internal_server_error: 500
    }
    render json: { error: message }, status: status_mapping[status] || status
  end

  def add_favorites_to_restaurants(restaurants)
    favorite_restaurant_ids = @current_user.favorites.pluck(:restaurant_id)
  
    restaurants.map do |restaurant|
      restaurant_record = Restaurant.find_by(place_id: restaurant[:place_id])
      if restaurant_record
        restaurant[:is_favorite] = favorite_restaurant_ids.include?(restaurant_record.id)
      else
        restaurant[:is_favorite] = false
      end
      restaurant
    end


    # favorite_records = @current_user.favorites.includes(:restaurant)
  
    # restaurants.map do |restaurant|
    # favorite = favorite_records.find { |fav| fav.restaurant.place_id == restaurant[:place_id] }
    # restaurant[:is_favorite] = favorite.present?
    # restaurant[:id] = favorite&.id
    # restaurant
  # end
  end

  def optional_authorize_request
    if request.headers['Authorization'].present?
      authorize_request
    end
  end

  def authorize_request
    authorize_request = AuthorizationService.new(request.headers)
    @current_user = authorize_request.current_user
  rescue JWT::VerificationError, JWT::DecodeError
    @current_user = nil
  end
end