class AddRatingAndCommentToFavorites < ActiveRecord::Migration[7.0]
  def change
    add_column :favorites, :rating, :integer
    add_column :favorites, :comment, :text
  end
end