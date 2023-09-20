class Api::RestaurantsController < ApplicationController
  def index
    # クライアントから送信された位置情報を受け取る
    client_latitude = params[:latitude]
    client_longitude = params[:longitude]

    if latitude.blank? || longitude.blank?
      render_error(:bad_request, '位置情報が提供されていません')
      return
    end
    
    client = GooglePlaces::Client.new(ENV['GOOGLE_API_KEY'])
    restaurants = client.spots(client_latitude, client_longitude, types: 'restaurant', language: 'ja', radius: 86)

    if restaurants.blank?
      render_error(:not_found, 'レストランが見つかりません')
      return
    end
    
    # レストラン情報を必要なプロパティに絞り込む
    simplified_restaurants = restaurants.map do |restaurant|
      {
        place_id: restaurant.place_id,
        name: restaurant.name,
        lat: restaurant.lat,
        lng: restaurant.lng,
        photo_url: photo_url(restaurant),
      }
    end

    render json: { status: 200, message: simplified_restaurants}
  end
  
  def show
    restaurant = Restaurant.find_by(id: params[:id])
    if restaurant
      render json: restaurant
    else
      render json: { error: 'レストランが見つかりません' }, status: :not_found
    end
  end

  def render_error(status, message)
    render json: { error: message }, status: status
  end

  private def photo_url(restaurant)
    client = GooglePlaces::Client.new(ENV['GOOGLE_API_KEY'])
    restaurant_details = client.spot(restaurant.place_id)
    if restaurant_details.present?
      return restaurant_details.photos.map do |restaurant_photo|
        {
          url: restaurant_photo.fetch_url(800)
        }
      end
    else
      return nil
    end
  end
end