class User < ApplicationRecord
  has_many :favorites
  has_many :restaurants, through: :favorites

  has_many :active_relationships, class_name: "FollowRelationship", foreign_key: "follower_id", dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed

  has_many :passive_relationships, class_name: "FollowRelationship", foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :follower
  
  def self.from_token_payload(payload)
    find_by(sub: payload['sub'])
  end

  def follow(other_user)
    FollowRelationship.create(follower_id: self.id, followed_id: other_user.id)
  end

  def unfollow(other_user)
    FollowRelationship.where(follower_id: self.id, followed_id: other_user.id).destroy_all
  end

  def following?(other_user)
    FollowRelationship.where(follower_id: self.id, followed_id: other_user.id).exists?
  end
end
