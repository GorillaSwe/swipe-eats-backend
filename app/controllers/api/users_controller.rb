class Api::UsersController < SecuredController
  skip_before_action :authorize_request, only: [:search, :get_user_profile]

  def create
    @user = User.find_or_initialize_by(sub: params[:sub]) do |user|
      user.email = params[:email]
      user.name = params[:name]
      user.picture = params[:picture]
    end

    if @user.save
      render json: @user, status: (@user.new_record? ? :created : :ok)
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def search
    query = params[:query]
    return render_error('Query is empty', :bad_request) if query.blank?

    users = User.where('name LIKE ?', "%#{query}%")
    render json: { users: users }
  end

  def get_user_profile
    user = find_user_by_sub(params[:user_sub])
    return render_error('User not found', :not_found) unless user

    render json: { name: user.name, picture: user.picture }
  end

  private

  def find_user_by_sub(sub)
    User.find_by(sub: URI.decode_www_form_component(sub))
  end

  def render_error(message, status)
    render json: { error: message }, status: status
  end
end