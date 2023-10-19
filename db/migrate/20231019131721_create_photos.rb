class CreatePhotos < ActiveRecord::Migration[7.0]
  def change
    create_table :photos do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.string :url
      t.integer :position

      t.timestamps
    end
  end
end
