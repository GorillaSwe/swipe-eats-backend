class Api::RestaurantsController < ApplicationController
  def index
    client = GooglePlaces::Client.new(ENV['GOOGLE_API_KEY'])
    restaurants = client.spots(35.681318174002534, 139.76713519281384)
    
    if restaurants
      # レストラン情報を必要なプロパティに絞り込む
      simplified_restaurants = restaurants.map do |restaurant|
        {
          place_id: restaurant.place_id,
          name: restaurant.name,
          lat: restaurant.lat,
          lng: restaurant.lng,
          photo_url: restaurant.photos[0].fetch_url(800)
        }
      end
      render json: { status: 200, message: simplified_restaurants}
    else
      render json: { error: 'スポットが見つかりません' }, status: :not_found
    end
  end
  
  def show
    restaurant = Restaurant.find_by(id: params[:id])
    if restaurant
      render json: restaurant
    else
      render json: { error: 'レストランが見つかりません' }, status: :not_found
    end
  end
end