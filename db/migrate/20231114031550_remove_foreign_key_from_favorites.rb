class RemoveForeignKeyFromFavorites < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :favorites, :restaurants
    remove_foreign_key :favorites, :users
  end
end