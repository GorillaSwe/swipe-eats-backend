class Api::RestaurantsController < ApplicationController
  def index
    client = GooglePlaces::Client.new(ENV['GOOGLE_API_KEY'])
    restaurants = client.spots(35.681318174002534, 139.76713519281384)
    render json: { status: 200, message: restaurants}
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