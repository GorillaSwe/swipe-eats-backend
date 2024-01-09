require "test_helper"

class FavoriteTest < ActiveSupport::TestCase
  def setup
    @user = users(:user_one)
    @restaurant = restaurants(:restaurant_one)
    @favorite = Favorite.create(user: @user, restaurant: @restaurant)
  end

  test "should belong to a user" do
    assert @favorite.user_id == @user.id
  end

  test "should belong to a restaurant" do
    assert @favorite.restaurant_id == @restaurant.id
  end

  test "should get latest favorites" do
    older_favorite = Favorite.create(user: @user, restaurant: @restaurant, created_at: 1.day.ago)
    newer_favorite = Favorite.create(user: @user, restaurant: @restaurant, created_at: 1.hour.ago)

    fixture_favorites = Favorite.where(id: [favorites(:favorite_one).id, favorites(:favorite_two).id])
    expected_result = [newer_favorite, @favorite, older_favorite] + fixture_favorites

    assert_equal expected_result.sort_by(&:created_at).reverse, Favorite.latest
  end
end