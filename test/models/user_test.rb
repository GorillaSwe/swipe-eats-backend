require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:user_one)
    @other_user = users(:user_two)
  end

  test "should have many favorites" do
    assert_respond_to @user, :favorites
  end

  test "should have many restaurants through favorites" do
    assert_respond_to @user, :restaurants
  end

  test "should have many active_relationships" do
    assert_respond_to @user, :active_relationships
  end

  test "should have many following" do
    assert_respond_to @user, :following
  end

  test "should have many passive_relationships" do
    assert_respond_to @user, :passive_relationships
  end

  test "should have many followers" do
    assert_respond_to @user, :followers
  end

  test "should follow and unfollow a user" do
    assert_not @user.following?(@other_user)
    @user.follow(@other_user)
    assert @user.following?(@other_user)
    assert @other_user.followers.include?(@user)
    @user.unfollow(@other_user)
    assert_not @user.following?(@other_user)
  end
end
