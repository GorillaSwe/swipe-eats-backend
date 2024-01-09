require "test_helper"

class FollowRelationshipTest < ActiveSupport::TestCase
  def setup
    @follower = users(:user_one)
    @followed = users(:user_two)
    @relationship = FollowRelationship.new(follower_id: @follower.id, followed_id: @followed.id)
  end

  test "should be valid" do
    assert @relationship.valid?
  end

  test "should require a follower_id" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end

  test "should require a followed_id" do
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end

  test "should belong to follower" do
    assert_equal @follower, @relationship.follower
  end

  test "should belong to followed" do
    assert_equal @followed, @relationship.followed
  end
end
