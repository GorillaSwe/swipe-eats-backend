class Api::FollowRelationshipsController < SecuredController
  skip_before_action :authorize_request, only: [:counts]

  def create
    user_sub = URI.decode_www_form_component(params[:user_sub])

    followed_user = User.find_by(sub: user_sub)
    if followed_user && followed_user != @current_user && !@current_user.following?(followed_user)
      @current_user.follow(followed_user)
      render json: { message: 'Followed successfully' }, status: :created
    else
      render json: { error: 'Unable to follow' }, status: :unprocessable_entity
    end
  end

  def index
    user_sub = URI.decode_www_form_component(params[:user_sub])

    followed_user = User.find_by(sub: user_sub)
    if followed_user && followed_user != @current_user
      is_following = @current_user.following?(followed_user)
      render json: { isFollowing: is_following }, status: :ok
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end

  def destroy_by_user_sub
    user_sub = URI.decode_www_form_component(params[:user_sub])

    followed_user = User.find_by(sub: user_sub)
    if followed_user && followed_user != @current_user && @current_user.following?(followed_user)
      @current_user.unfollow(followed_user)
      render json: { message: 'Unfollowed successfully' }, status: :ok
    else
      render json: { error: 'Unable to unfollow' }, status: :unprocessable_entity
    end
  end

  def counts
    user_sub = URI.decode_www_form_component(params[:user_sub])
    user = User.find_by(sub: user_sub)

    if user
      following_count = user.following.count
      followers_count = user.followers.count

      render json: {
        followingCount: following_count,
        followersCount: followers_count
      }, status: :ok
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end
end