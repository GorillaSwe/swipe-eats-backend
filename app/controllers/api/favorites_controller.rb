class Api::UsersController < SecuredController
  def create
    existing_favorite = @current_user.favorites.find_by(restaurant_id: params[:restaurant_id])

    if existing_favorite.nil?
      favorite = @current_user.favorites.build(restaurant_id: params[:restaurant_id])

      if favorite.save
        render json: favorite, status: :created
      else
        render json: favorite.errors, status: :unprocessable_entity
      end
    end
  end
end
