class Api::UsersController < SecuredController
  skip_before_action :authorize_request, only: [] 
  def create
    @user = User.find_or_create_by(uid: params[:sub]) do |user|
      user.email = params[:email]
      user.name = params[:name]
      user.picture = params[:picture]
    end

    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end
end