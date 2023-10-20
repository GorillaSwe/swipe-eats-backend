class CreatePhotos < ActiveRecord::Migration[7.0]
  def change
    create_table :photos do |t|
      t.references :restaurant, null: false
      t.string :url
      t.integer :position

      t.timestamps
    end
  end
end
