class Api::FollowRelationshipsController < SecuredController
  skip_before_action :authorize_request, only: [:counts, :following, :followers]

  before_action :set_user_by_sub, only: [:create, :index, :destroy_by_user_sub, :counts, :following, :followers]

  def create
    return render json: { error: 'Unable to follow' }, status: :unprocessable_entity unless valid_follow_action?

    @current_user.follow(@user)
    render json: { message: 'Followed successfully' }, status: :created
  end

  def index
    render json: { isFollowing: @current_user.following?(@user) }, status: :ok
  end

  def destroy_by_user_sub
    return render json: { error: 'Unable to unfollow' }, status: :unprocessable_entity unless valid_unfollow_action?

    @current_user.unfollow(@user)
    render json: { message: 'Unfollowed successfully' }, status: :ok
  end

  def counts
    return render json: { error: 'User not found' }, status: :not_found unless @user

    following_count = @user.following.count
    followers_count = @user.followers.count

    render json: {
      followingCount: following_count,
      followersCount: followers_count
    }, status: :ok
  end

  def following
    return render json: { error: 'User not found' }, status: :not_found unless @user
  
    following_users = @user.following
    render json: { following: following_users }, status: :ok
  end
  
  def followers
    return render json: { error: 'User not found' }, status: :not_found unless @user
  
    follower_users = @user.followers
    render json: { followers: follower_users }, status: :ok
  end

  private

  def set_user_by_sub
    user_sub = URI.decode_www_form_component(params[:user_sub])
    @user = User.find_by(sub: user_sub)
  end

  def valid_follow_action?
    @user && @user != @current_user && !@current_user.following?(@user)
  end

  def valid_unfollow_action?
    @user && @user != @current_user && @current_user.following?(@user)
  end
end