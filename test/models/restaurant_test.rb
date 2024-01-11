require "test_helper"

class RestaurantTest < ActiveSupport::TestCase
  def setup
    @restaurant = Restaurant.new(
      place_id: "abcd1234",
      name: "テストレストラン",
      lat: 35.6895,
      lng: 139.6917
    )
  end

  test "should be valid" do
    assert @restaurant.valid?
  end

  test "should require a place_id" do
    @restaurant.place_id = nil
    assert_not @restaurant.valid?
  end

  test "place_id should be unique" do
    duplicate_restaurant = @restaurant.dup
    @restaurant.save
    assert_not duplicate_restaurant.valid?
  end

  test "should require a name" do
    @restaurant.name = nil
    assert_not @restaurant.valid?
  end

  test "should require a lat" do
    @restaurant.lat = nil
    assert_not @restaurant.valid?
  end

  test "should require a lng" do
    @restaurant.lng = nil
    assert_not @restaurant.valid?
  end

  test "should have many photos" do
    assert_respond_to @restaurant, :photos
  end

  test "should have many favorites" do
    assert_respond_to @restaurant, :favorites
  end

  test "should have many users through favorites" do
    assert_respond_to @restaurant, :users
  end
end
