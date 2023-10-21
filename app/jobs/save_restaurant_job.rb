class SaveRestaurantJob < ApplicationJob
  queue_as :default

  def perform(restaurant_detail)
    # レストラン情報をデータベースに保存
    restaurant = Restaurant.find_or_initialize_by(place_id: restaurant_detail[:place_id])
    restaurant.assign_attributes(
      name: restaurant_detail[:name],
      lat: restaurant_detail[:lat],
      lng: restaurant_detail[:lng],
      vicinity: restaurant_detail[:vicinity],
      rating: restaurant_detail[:rating],
      price_level: restaurant_detail[:price_level],
      website: restaurant_detail[:website],
      url: restaurant_detail[:url],
      postal_code: restaurant_detail[:postal_code],
      user_ratings_total: restaurant_detail[:user_ratings_total],
      formatted_phone_number: restaurant_detail[:formatted_phone_number]
    )
    restaurant.save!

    # 写真情報をデータベースに保存
    restaurant_detail[:photos].each_with_index do |photo_reference, index|
      photo_instance = GooglePlaces::Photo.new(nil, nil, photo_reference, nil, ENV['GOOGLE_API_KEY'])
      photo_url = photo_instance.fetch_url(580)

      photo = restaurant.photos.find_or_initialize_by(url: photo_url)
      photo.position = index
      unless photo.save
        Rails.logger.error("Photo save error: #{photo.errors.full_messages.join(', ')}")
      end
    end
  end
end