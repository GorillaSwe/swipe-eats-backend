class Api::UsersController < SecuredController
  skip_before_action :authorize_request, only: [:search, :profile]

  def create
    @user = User.find_or_initialize_by(sub: params[:sub]) do |user|
      user.email = params[:email]
      user.name = params[:name]
      user.picture = params[:picture]
    end

    if @user.new_record?
      if @user.save
        render json: @user, status: :created
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    else
      render json: @user, status: :ok
    end
  end

  def search
    query = params[:query]
    if query.present?
      users = User.where('name LIKE ?', "%#{query}%")
      render json: { users: users }
    else
      render json: { error: 'Query is empty' }, status: :bad_request
    end
  end

  def profile
    user_sub = URI.decode_www_form_component(params[:user_sub])
    user = User.find_by(sub: user_sub)

    if user
      render json: { name: user.name, picture: user.picture }
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end
end