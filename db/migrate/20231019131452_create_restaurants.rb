class CreateRestaurants < ActiveRecord::Migration[7.0]
  def change
    create_table :restaurants do |t|
      t.string :place_id
      t.string :name
      t.float :lat
      t.float :lng
      t.string :vicinity
      t.float :rating
      t.integer :price_level
      t.string :website
      t.string :url
      t.string :postal_code
      t.integer :user_ratings_total
      t.string :formatted_phone_number

      t.timestamps
    end
  end
end
