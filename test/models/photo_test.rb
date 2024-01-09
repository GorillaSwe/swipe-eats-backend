require "test_helper"

class PhotoTest < ActiveSupport::TestCase
  def setup
    @restaurant = restaurants(:restaurant_one)
    @photo = Photo.new(
      restaurant: @restaurant,
      url: "http://example.com/photo.jpg",
      position: 1
    )
  end

  test "should be valid" do
    assert @photo.valid?
  end

  test "should require a url" do
    @photo.url = nil
    assert_not @photo.valid?
  end

  test "should require a position" do
    @photo.position = nil
    assert_not @photo.valid?
  end

  test "position should be a number" do
    @photo.position = 'a'
    assert_not @photo.valid?
  end

  test "should belong to a restaurant" do
    assert_equal @photo.restaurant_id, @restaurant.id
  end
end
